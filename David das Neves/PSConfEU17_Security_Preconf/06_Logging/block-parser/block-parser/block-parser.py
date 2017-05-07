#   Copyright 2016, Matthew Dunwoody
#   dunwoody.matthew@gmail.com
#   @matthewdunwoody
#
#   Built on Willi Ballenthin's Python-EVTX https://github.com/williballenthin/python-evtx
#
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.
#
#   Version 1.0
import os
import argparse

from collections import defaultdict

from lxml import etree
from lxml.etree import XMLSyntaxError

from Evtx.Evtx import Evtx
from Evtx.Views import evtx_file_xml_view

def to_lxml(record_xml):
    """
    @type record: Record
    """
    return etree.fromstring("<?xml version=\"1.0\" encoding=\"utf-8\" standalone=\"yes\" ?>%s" %
            record_xml.replace("xmlns=\"http://schemas.microsoft.com/win/2004/08/events/event\"", ""))
            
class ScriptBlockEntry(object):
    def __init__(self, level, computer, timestamp, message_number, message_total, script_block_id, script_block_text):
        super(ScriptBlockEntry, self).__init__()
        self.level = level
        self.computer = computer
        self.timestamp = timestamp
        self.message_number = message_number
        self.message_total = message_total
        self.script_block_id = script_block_id
        self.script_block_text = script_block_text
    
    def get_metadata(self):
        return self.script_block_id + "," + str(self.timestamp) + "," + str(self.level) + "," + str(self.message_total) + "," + self.computer + "," + str(self.message_number) 

class Entry(object):
    def __init__(self, xml, record):
        super(Entry, self).__init__()
        self._xml = xml
        self._record = record
        self._node = to_lxml(self._xml)
        
    def get_xpath(self, path):
        return self._node.xpath(path)[0]

    def get_eid(self):
        return int(self.get_xpath("/Event/System/EventID").text)
            
    def get_script_block_entry(self):
        level = int(self.get_xpath("/Event/System/Level").text)
        computer = self.get_xpath("/Event/System/Computer").text
        timestamp = self._record.timestamp()
        message_number = int(self.get_xpath("/Event/EventData/Data[@Name='MessageNumber']").text)
        message_total = int(self.get_xpath("/Event/EventData/Data[@Name='MessageTotal']").text)
        script_block_id = self.get_xpath("/Event/EventData/Data[@Name='ScriptBlockId']").text
        script_block_text = self.get_xpath("/Event/EventData/Data[@Name='ScriptBlockText']").text
        return ScriptBlockEntry(level, computer, timestamp, message_number, message_total, script_block_id, script_block_text)
        
def get_entries(evtx):
    """
    @rtype: generator of Entry
    """
    try:
        for xml, record in evtx_file_xml_view(evtx.get_file_header()):
            try:
                yield Entry(xml, record)
            except: # etree.XMLSyntaxError as e:
                continue
    except:
        yield None

def get_entries_with_eids(evtx, eids):
    """
    @type eids: iterable of int
    @rtype: generator of Entry
    """
    for entry in get_entries(evtx):
        try:
            if entry != None and entry.get_eid() in eids:
                yield entry
        except:
            continue

def process_entries(entries, s, a, o, f, m):
    blocks = defaultdict(list)
    metadata = {}

    for entry in entries:
        sbe = entry.get_script_block_entry()
        if s == sbe.script_block_id or ((a or sbe.message_total > 1) and s == None):
            blocks[sbe.script_block_id].insert(sbe.message_number, sbe.script_block_text.replace("&lt;",">").replace("&gt;","<"))
            if not metadata.has_key(sbe.script_block_id):
                metadata[sbe.script_block_id] = sbe
    
    output_result(blocks, metadata, o, f, m)

def output_result(blocks, metadata, o, f, m):
    divider = "\n~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n"
    header = "Script Block ID,Timestamp,Level,Path,Message Total,Computer,First Message Number"

    if blocks:
        if f:
            if not os.path.isdir(os.path.dirname(f)):
                os.makedirs(os.path.dirname(f))
            fw = open(f, "w")
            k = blocks.keys()
            for n in k:
                if metadata[n].message_number > 1:
                    x = " -partial"
                else:
                    x = ""
                fw.write(divider + metadata[n].script_block_id + x + divider)
                fw.write("".join(blocks[n]))
            fw.close()
        elif o:
            if not os.path.isdir(o):
                os.makedirs(o)
            k = blocks.keys()
            for n in k:
                if metadata[n].message_number > 1:
                    x = "-partial"
                else:
                    x = ""
                fw = open(os.path.join(o, n + x + ".ps1_"), "w")
                fw.write("".join(blocks[n]))
                fw.close()

        if m:
            if not os.path.isdir(os.path.dirname(m)):
                os.makedirs(os.path.dirname(m))
            fw = open(m, "w")
            fw.write(header)
            k = blocks.keys()
            for n in k:
                fw.write("\n" + metadata[n].get_metadata())
            fw.close()
            
    else:
        print "No blocks found"

def main():
    import argparse
    parser = argparse.ArgumentParser(
        description="Parse PowerShell script block log entries (EID 4104) out of the Microsoft-Windows-PowerShell%4Operational.evtx event log. By default, reconstructs all multi-message blocks.")
    parser.add_argument("evtx", type=str,
                        help="Path to the Microsoft-Windows-PowerShell%%4Operational.evtx event log file to parse")
    parser.add_argument("-m",  "--metadata", type=str,
                        help="Output script block metadata to CSV. Specify output file.")
    parser.add_argument("-s", "--scriptid", type=str,
                        help="Script block ID to parse. Use with -f or -o")
    parser.add_argument("-f", "--file", type=str,
                        help="Write blocks to a single file. Specify output file.")
    parser.add_argument("-o", "--output", type=str,
                        help="Output directory for script blocks.")
    parser.add_argument("-a", "--all", action='store_true',
                        help="Output all blocks.")
    args = parser.parse_args()

    with Evtx(args.evtx) as evtx:
        process_entries(get_entries_with_eids(evtx, set([4104])), args.scriptid, args.all, args.output, args.file, args.metadata)
        pass

if __name__ == "__main__":
    main()
