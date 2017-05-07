#region BriefHelp
function Get-BriefHelp {
    param(
        $Name
    )
    (Get-Help $Name).Parameters.Parameter |
    Select-Object Name,@{n='Help';e={-join $_.Description.Text}}
}
#endregion



#region JEA Role file
New-PSRoleCapabilityFile -Path .\PSConfEUFirstJEARole.psrc

psedit .\PSConfEUFirstJEARole.psrc

Get-BriefHelp -Name New-PSRoleCapabilityFile

$RoleSplat = @{
    VisibleCmdlets = 'Get-Process', 'Get-CimInstance'
}
New-PSRoleCapabilityFile -Path .\FirstJEA.psrc @RoleSplat

Get-Content .\FirstJEA.psrc

(Get-Content .\FirstJEA.psrc) -replace '^#.*$' |
Where-Object {$_}

New-PSSessionConfigurationFile -SessionType RestrictedRemoteServer -Path .\PSConfEUFirstJEAConf.pssc

(Get-Content .\PSConfEUFirstJEAConf.pssc) -replace '^#.*$' |
Where-Object {$_}

#endregion


#region Deploy role capability file
Expand-Archive -Path .\Demo1JEA.zip -DestinationPath 'C:\Program Files\WindowsPowerShell\Modules\'

Get-ChildItem -Path 'C:\Program Files\WindowsPowerShell\Modules\Demo1JEA' -Recurse |
Select-Object -Property FullName

Get-ChildItem -Path 'C:\Program Files\WindowsPowerShell\Modules\Demo1JEA\' -File |
Get-Content
#endregion


#region Configuration file
Get-BriefHelp New-PSSessionConfigurationFile

$ConfSplat = @{
    RunAsVirtualAccount = $true
    RoleDefinitions     = @{'JaapBrasser' = @{RoleCapabilities = 'FirstJEA'}}
    SessionType         = 'RestrictedRemoteServer'
    Path                = '.\JEAConfig.pssc'
}

New-PSSessionConfigurationFile @ConfSplat
Test-PSSessionConfigurationFile -Path $ConfSplat.Path
#endregion


#region Register Configuration
Get-PSSessionConfiguration | Select-Object Name

$RegisterSplat = @{
    Name  = 'MyFirstJEA'
    Path  = '.\JEAConfig.pssc'
    Force = $true
}
Register-PSSessionConfiguration @RegisterSplat

Get-BriefHelp Enter-PSSession

whoami
$JEASession = New-PSSession -ConfigurationName 'MyFirstJEA' -ComputerName .

Invoke-Command -Session $JEASession -ScriptBlock {Get-Process}

Enter-PSSession -Session $JEASession
Get-Command
Get-Process
$PS = Get-Process
Exit-PSSession

$PS = Invoke-Command -Session $JEASession -ScriptBlock {Get-Process}

$PS[0..5]

Get-CimInstance -ClassName Win32_Bios

Get-PSSessionConfiguration | Select Name
#endregion


#region Update JEA Configuration on the fly
notepad
Invoke-Command -Session $JEASession -ScriptBlock {Get-Process notepad}
Invoke-Command -Session $JEASession -ScriptBlock {Get-Process notepad | Stop-Process}

psedit 'C:\Program Files\WindowsPowerShell\Modules\Demo1JEA\RoleCapabilities\FirstJEA.psrc'

Invoke-Command -Session $JEASession -ScriptBlock {Get-Process notepad | Stop-Process}

$JEASession = New-PSSession -ConfigurationName 'MyFirstJEA' -ComputerName .
Invoke-Command -Session $JEASession -ScriptBlock {Get-Process notepad | Stop-Process}


#endregion


#region Cleanup
Unregister-PSSessionConfiguration -Name MyFirstJEA -Force

Get-Item -Path 'C:\Program Files\WindowsPowerShell\Modules\Demo1JEA\' |
Remove-Item -Recurse
#endregion

