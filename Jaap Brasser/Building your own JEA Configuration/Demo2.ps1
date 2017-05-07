#region Introduce the users
echo HelpDeskUser HyperVAdmin |
ForEach-Object {
    Get-ADUser $_
}

$Cred = @{
    HelpDeskUser = Get-Credential awesome\HelpDeskUser
    HyperVAdmin  = Get-Credential awesome\HyperVAdmin
}

$Cred | Export-Clixml -Path .\Credentials.xml

$Cred = Import-CliXml -Path .\Credentials.xml

$Cred
#endregion


#region Prepare role file and folder structure
$NewItem = @{
    Path     = 'C:\Program Files\WindowsPowerShell\Modules'
    Name     = 'JEAConfigurations'
    ItemType = 'Directory'
}
New-Item @NewItem


$NewItem = @{
    Path     = 'C:\Program Files\WindowsPowerShell\Modules\JEAConfigurations'
    Name     = 'RoleCapabilities'
    ItemType = 'Directory'
}
New-Item @NewItem


$NewItem = @{
    Path     = 'C:\Program Files\WindowsPowerShell\Modules\JEAConfigurations'
    Name     = 'JEAConfigurations.psm1'
    ItemType = 'File'
}
New-Item @NewItem


$Manifest = @{
    Path       = 'C:\Program Files\WindowsPowerShell\Modules\JEAConfigurations\JEAConfigurations.psd1'
    RootModule = "JEAConfigurations.psm1"
}
New-ModuleManifest @Manifest

Get-ChildItem -Path 'C:\Program Files\WindowsPowerShell\Modules\JEAConfigurations' -Recurse |
Select-Object -Property FullName
#endregion


#region JEA Role files creation and registration
$RoleSplat = @{
    VisibleCmdlets          = 'Get-ADComputer', 'Get-AdUser', 'Unlock-ADAccount', 'Disable-ADAccount', 'Set-ADAccountPassword'
    VisibleExternalCommands = 'C:\Windows\System32\whoami.exe'
    Path                    = 'C:\Program Files\WindowsPowerShell\Modules\JEAConfigurations\RoleCapabilities\HelpDeskUser.psrc'
}
New-PSRoleCapabilityFile @RoleSplat

$ConfSplat = @{
    RunAsVirtualAccount = $true
    RoleDefinitions     = @{'Awesome\HelpDeskUser' = @{RoleCapabilities = 'HelpDeskUser','Doesnotexist'}}
    SessionType         = 'RestrictedRemoteServer'
    Path                = 'C:\Program Files\WindowsPowerShell\Modules\JEAConfigurations\HelpDeskUser.pssc'

}
New-PSSessionConfigurationFile @ConfSplat

$RegisterSplat = @{
    Name  = 'awesome.helpdesk.accountmanagement'
    Path  = 'C:\Program Files\WindowsPowerShell\Modules\JEAConfigurations\HelpDeskUser.pssc'
    Force = $true
}
Register-PSSessionConfiguration @RegisterSplat


#endregion


#region Connect to configuration
Get-PSSessionConfiguration | Select-Object Name

$Cred

# Connect as HyperV admin
$SessionSplat = @{
    ConfigurationName = 'awesome.helpdesk.accountmanagement'
    ComputerName      = '.'
    Credential        = $Cred.HyperVAdmin
}
$HelpDeskSession = New-PSSession @SessionSplat

# Highlight user account
(Get-Content 'C:\Program Files\WindowsPowerShell\Modules\JEAConfigurations\HelpDeskUser.pssc') -replace '^#.*$' |
Where-Object {$_}

# Import helpdesk session
$SessionSplat = @{
    ConfigurationName = 'awesome.helpdesk.accountmanagement'
    ComputerName      = '.'
    Credential        = $Cred.HelpDeskUser
}
$HelpDeskSession = New-PSSession @SessionSplat

Invoke-Command -Session $HelpDeskSession -ScriptBlock {
    whoami.exe
}

Invoke-Command -Session $HelpDeskSession -ScriptBlock {
    Get-ADUser UserA
}

Invoke-Command -Session $HelpDeskSession -ScriptBlock {
    Get-ADComputer -Filter *
}

Invoke-Command -Session $HelpDeskSession -ScriptBlock {
    Get-ADUser UserA | Unlock-ADAccount -Verbose
}

Invoke-Command -Session $HelpDeskSession -ScriptBlock {
    Get-ADUser UserA | 
    Set-ADAccountPassword
}

Invoke-Command -Session $HelpDeskSession -ScriptBlock {
    Get-ADUser Administrator
}

Invoke-Command -Session $HelpDeskSession -ScriptBlock {
    Get-ADUser Administrator |
    Disable-ADAccount -WhatIf
}
#endregion


#region Reconfigure Role capability

<#
FunctionDefinitions = @{
    Name = 'Get-User'

    ScriptBlock = {
        param($Identity)
        Get-ADUser -Identity $Identity -SearchBase 'CN=Users,DC=awesome,DC=com' |
        Where-Object {$_.Name -ne 'Administrator'}
    }
}
#>
psedit 'C:\Program Files\WindowsPowerShell\Modules\JEAConfigurations\RoleCapabilities\HelpDeskUser.psrc'

Invoke-Command -Session $HelpDeskSession -ScriptBlock {
    Get-Command Get-ADUser
}

$SessionSplat = @{
    ConfigurationName = 'awesome.helpdesk.accountmanagement'
    ComputerName      = '.'
    Credential        = $Cred.HelpDeskUser
}
$HelpDeskSession = New-PSSession @SessionSplat

Invoke-Command -Session $HelpDeskSession -ScriptBlock {
    Get-Command Get-ADUser
    Get-Command Get-User
}

Invoke-Command -Session $HelpDeskSession -ScriptBlock {
    Get-User -Identity UserA
}

Invoke-Command -Session $HelpDeskSession -ScriptBlock {
    Get-User -Identity Administrator
}
#endregion

