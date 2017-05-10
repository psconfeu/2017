<#
    $author = T. Butz 
    $version = 2013.04.27
    $url = 'www.thorsten-butz.de'; $twitter = $adn = '@thorstenbutz'

    This demo script enables "Run as administrator" for the built-in File Explorer 
    aka "explorer.exe" in Windows NT 6.x.
    This is accomplished by renaming the registry key as follows:
    'HKEY_CLASSES_ROOT\AppID\{CDCBCFCA-3CDC-436f-A4E2-0E02075250C2}\RunAs'    

    Thanks to Sami Laiho and Tagoror Sundstrom who published this workaround:
    http://idealinfra.blogspot.fi/2012/09/run-explorer-as-admin.html
		
    For security reasons this key is protected by the "Trusted Installer" ownership.
    Due to a shortcoming in the Set-ACL cmdlet, the modfification is done by Helge Klein's 
    freeware tool SETACL.EXE:
    http://helgeklein.com/setacl/
    Thank you, Helge, for providing this cute tool. 
#>

function psunzip ($zip) { 
    $shell = New-Object -com Shell.Application
    $folder = $Shell.NameSpace((split-path $zip))
    $folder.Copyhere($Shell.NameSpace($zip).items(),1040)
}

$u = 'http://files.helgeklein.com/downloads/SetACL/current/SetACL%20(executable%20version).zip'

# Getting simple file name .. 
New-Variable "f" -Value ((Get-Variable "u").Value.split("/") | Select-Object -last 1)

Push-Location

# Create temp path
Do {$p = "$env:tmp\setacl" + (Get-Random) } while (Test-Path $p)

mkdir $p | Out-Null ; Set-Location $p
"WORKING DIRECTORY: $pwd"

# Downloading SETACL.EXE
$client = New-Object System.Net.WebClient
$client.DownloadFile( $u, "$p\$f" ) 

psunzip "$p\$f"

if     ($env:PROCESSOR_ARCHITECTURE -match "64") { $arch = "64 bit" }
elseif ($env:PROCESSOR_ARCHITECTURE -match "32") { $arch = "32 bit" }
else   {"Unknown CPU type, quitting .."; exit }

$setacl = (Get-ChildItem $p -Filter setacl.exe -Recurse | Where-Object { $_.Fullname -match $arch }).FullName
if ($setacl.count -ne 1) { "SETACL.EXE not found, quitting."; exit }
"PATH TO SETACL.EXE: $setacl"

$key = 'HKEY_CLASSES_ROOT\AppID\{CDCBCFCA-3CDC-436f-A4E2-0E02075250C2}'
& $SetACL -on $key -ot reg -actn setowner -ownr "n:$env:USERDOMAIN\$env:username" 
& $SetACL -on $key -ot reg -actn ace -ace "n:$env:USERDOMAIN\$env:username;p:full"

Rename-ItemProperty 'RunAs' -NewName 'RunA_' -Path Registry::$key -ea 0 
Get-ItemProperty registry::$key | Select-Object R*

Pop-Location

# Cleaning up!
Remove-Item -Path $p -Confirm:0 -Recurse