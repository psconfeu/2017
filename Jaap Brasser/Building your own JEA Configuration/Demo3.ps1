#region JEA Role files creation and registration
$RoleSplat = @{
    VisibleCmdlets          = 'Get-VM', 'Start-VM', 'Stop-VM'
    VisibleExternalCommands = 'C:\Windows\System32\whoami.exe'
    Path                    = 'C:\Program Files\WindowsPowerShell\Modules\JEAConfigurations\RoleCapabilities\HyperVAdmin.psrc'
}
New-PSRoleCapabilityFile @RoleSplat

$ConfSplat = @{
    RunAsVirtualAccount = $true
    RoleDefinitions     = @{'Awesome\HyperVAdmin' = @{RoleCapabilities = 'HyperVAdmin'}}
    SessionType         = 'RestrictedRemoteServer'
    Path                = 'C:\Program Files\WindowsPowerShell\Modules\JEAConfigurations\HyperVAdmin.pssc'

}
New-PSSessionConfigurationFile @ConfSplat

$RegisterSplat = @{
    Name  = 'awesome.hyperv.vmmanagement'
    Path  = 'C:\Program Files\WindowsPowerShell\Modules\JEAConfigurations\HyperVAdmin.pssc'
    Force = $true
}
Register-PSSessionConfiguration @RegisterSplat


#endregion


#region Connect to configuration
Get-PSSessionConfiguration | Select-Object Name

# Connect as HyperV admin
$SessionSplat = @{
    ConfigurationName = 'awesome.hyperv.vmmanagement'
    ComputerName      = '.'
    Credential        = $Cred.HyperVAdmin
}
$HyperVSession = New-PSSession @SessionSplat

Invoke-Command -Session $HyperVSession -ScriptBlock {
    Get-VM
}

Invoke-Command -Session $HyperVSession -ScriptBlock {
    Get-VM NormalVM01 | Start-VM -WhatIf
}
#endregion


#region GUI JEA
# Start-VM
Invoke-Command -Session $HyperVSession -ScriptBlock {Get-VM} |
Out-GridView -Title 'Select VM to Start' -PassThru |
ForEach-Object {
    $CurrentVM = $_
    Invoke-Command -Session $HyperVSession {
        Start-VM $using:CurrentVM.Name -Whatif
    }
}
#endregion


#region Cleanup
Unregister-PSSessionConfiguration -Name 'awesome.helpdesk.accountmanagement' -Force
Unregister-PSSessionConfiguration -Name 'awesome.hyperv.vmmanagement' -Force

Get-Item -Path 'C:\Program Files\WindowsPowerShell\Modules\JEAConfigurations\' |
Remove-Item -Recurse
#endregion