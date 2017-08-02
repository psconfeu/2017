function Update-NanoServer
 {
    param(
    [Parameter(mandatory=$true)]
    [string]$ServerName,
 
    [Parameter(mandatory=$false)]
    [switch]$InstallRequired,
 
    [Parameter(mandatory=$false)]
    [switch]$ForceReboot
    )
 
 
    #Search Updates
    $cimSession = New-CimInstance -Namespace root/Microsoft/Windows/WindowsUpdate -ClassName MSFT_WUOperationsSession -CimSession $ServerName
    $scanResults = Invoke-CimMethod -InputObject  $cimSession -MethodName ScanForUpdates -Arguments @{SearchCriteria="IsInstalled=0";OnlineScan=$true}
 
    #display available Updates
    $scanResults.Updates | Select Title,KBArticleID
 
 
    #Install Updates
    If ($InstallRequired)
    {
     If (($scanResults.Updates).count -gt 0)
     {
 
     Write-Output "Installing Updates"
     $scanResults = Invoke-CimMethod -InputObject $cimSession -MethodName ApplyApplicableUpdates
 
    If ($ForceReboot)
     {
     Write-Output "Restarting Node $ServerName"
     Invoke-Command -ComputerName $ServerName -ScriptBlock {Restart-Computer -Force}
     }
     }
     Else
     {
     Write-Warning "No applicaple Updates found"
     }
    }
}