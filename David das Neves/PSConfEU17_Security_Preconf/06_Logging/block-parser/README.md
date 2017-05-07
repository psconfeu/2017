purpose
=======

'block-parser' is a tool for parsing Windows PowerShell script block logging events. Script block logging records all PowerShell code invoked on a system, which provides valuable forensic and auditing data. However, this data is recorded in event log format and can be fragmented into multiple events. In the case of some large scripts, like Invoke-Mimikatz, hundreds of event log entries can result. This script parses script block logging events to output easily readable and executable code.

technique
=========

PowerShell script block logging records all code executed by the PowerShell scripting engine. Each "block" of code that is executed (commands, scripts, etc.) is recorded in a event log entry with a unique script block ID. When a script block exceeds the maximum size of an event log message, it is split into multiple event log entries. Each of these entries will have the same script block ID and will record the sequence number of the entry, along with the total number of entries associated with that script block. This tool parses and outputs the full contents of script blocks, based on their script block IDs.

> and < characters in the recorded PowerShell code are encoded in the event log. 'block-parser' reverses this substitution with a simple string replacement.

Script block logging events are recorded in Event ID (EID) 4104 within the Microsoft-Windows-PowerShell%4Operational.evtx event log. 

For additional information see my blog post: https://www.fireeye.com/blog/threat-research/2016/02/greater_visibilityt.html

example usage
=============

Parse all multi-part script blocks from a log to separate files:

  > python block-parser.py -o C:\path C:\data\Microsoft-Windows-PowerShell%4Operational.evtx
  
Parse ALL script blocks to a single output file:
  
  > python block-parser.py -a -f C:\path\file.txt C:\data\Microsoft-Windows-PowerShell%4Operational.evtx
  
Parse metadata for ALL script blocks:

 > python block-parser.py -a -m C:\path\metadata.csv C:\data\Microsoft-Windows-PowerShell%4Operational.evtx
 
Parse a specified script block with metadata:

> python block-parser.py -o C:\path -s 00000000-0000-0000-0000-000000000000 -m C:\path\metadata.csv C:\data\Microsoft-Windows-PowerShell%4Operational.evtx

Each command supports:

--output or --file, 
--scriptid or --all, 
--metadata

limitations
===========

When the PowerShell operational log rolls, some entries for a multi-part script block may be lost. If that occurs "-partial" will be appended to the file name or script block ID in output files, and the "First Message Number" in the metadata for the corresponding script block ID will be greater than one.

credit where credit is due
============

This tool is built on Willi Ballenthin's excellent python-EVTX and contains code cannibalized from Willi's process-forest.

https://github.com/williballenthin/python-evtx.

https://github.com/williballenthin/process-forest
