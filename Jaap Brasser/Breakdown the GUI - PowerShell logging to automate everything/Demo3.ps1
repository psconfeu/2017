#region Demo show Procmon capabilities
Invoke-Item 'C:\PSConfEU\Sessions\Breakdown the GUI - PowerShell logging to automate everything\Procmon\Procmon.exe'

CTRL E

CTRL X

CTRL R

CTRL
#endregion


#region Show procmon PowerShell Copy-Item GUI

# Show filter

# Copy test-file to desktop

Copy-Item .\Test.file $home\desktop\

Remove-Item $home\desktop\Test.file
#endregion


#region Show procmon PowerShell Copy-Item Script
#$Output = Import-CliXml -Path .\MockOutput.xml

$DefaultExclusions = 'ProcessName,is,Procmon.exe,Exclude
ProcessName,is,Procexp.exe,Exclude
ProcessName,is,Autoruns.exe,Exclude
ProcessName,is,Procmon64.exe,Exclude
ProcessName,is,Procexp.exe,Exclude
ProcessName,is,System,Exclude' -split "`n" -join ';'

$Output = .\Start-ProcMon.ps1 -Filter "Path,beginswith,C:\Users\JaapBrasser\Desktop,Include;$DefaultExclusions" -Duration 10

Copy-Item .\Test.file $home\desktop\ -Force

$Output

$Output | Measure-Object

$Output | Get-Member

$Output[0]

$Output | Group-Object -Property 'Process Name'

($Output | Group-Object -Property 'Process Name').Group |
Where-Object {$_.Operation -eq 'CreateFile' -and $_.Path -eq 'C:\Users\JaapBrasser\Desktop\Test.file'}

($Output | Group-Object -Property 'Process Name').Group |
Where-Object {$_.Operation -eq 'CreateFile' -and $_.Path -eq 'C:\Users\JaapBrasser\Desktop\Test.file'} |
Format-Table -AutoSize


($Output | Group-Object -Property 'Process Name')[1].Group |
Where-Object {$_.Operation -eq 'CreateFile'} |
Format-Table -AutoSize

Get-Process -Id 12960
#endregion


#region Show procmon Storage Sense settings
$Output = .\Start-ProcMon.ps1 -Filter "Operation,is,RegSetValue,Include;$DefaultExclusions" -Duration 10

$Output

$Output | Group-Object -Property 'Process Name'

($Output | Group-Object -Property 'Process Name')[3].group

$Output = .\Start-ProcMon.ps1 -Filter "Operation,is,RegSetValue,Include;ProcessName,is,SystemSettings.exe,Include;$DefaultExclusions" -Duration 10

$Output
#endregion


#region Show process of building Storage Sense script
    [ordered]@{
        StorageSenseEnabled    = (Get-ItemPropertyValue -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\StorageSense\Parameters\StoragePolicy\' -Name 01) -as [bool]
        RemoveAppFilesEnabled  = (Get-ItemPropertyValue -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\StorageSense\Parameters\StoragePolicy\' -Name 04) -as [bool]
        ClearRecycleBinEnabled = (Get-ItemPropertyValue -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\StorageSense\Parameters\StoragePolicy\' -Name 08) -as [bool]
    }
#endregion