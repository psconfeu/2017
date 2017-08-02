# DSC

$ConfigurationData = 
@{
 AllNodes = 
 @(
 @{
 NodeName = '*'
 WSUSServer = 'http://wsus01.legendary.local:8530'
 WSUSTargetGroup = 'PSConfEU2017'
 } );
 }

Configuration WSUSAutoDL
{
 param(
 [Parameter(mandatory=$true)]
 [string[]]$NodeName
 )
 
 Node $NodeName
 {
 Registry UpdateServer
 {
 Key = 'HKLM:\Software\Policies\Microsoft\Windows\WindowsUpdate' 
 ValueName = 'WUServer'
 ValueData = 'http://wsus01.legendary.local:8530'
 ValueType = 'String'
 Ensure = 'Present'
 }

Registry StatusServer
 {
 Key = 'HKLM:\Software\Policies\Microsoft\Windows\WindowsUpdate' 
 ValueName = 'WUStatusServer'
 ValueData = 'http://wsus01.legendary.local:8530'
 ValueType = 'String'
 Ensure = 'Present'
 }

Registry UpdateTargetGroup
 {
 Key = 'HKLM:\Software\Policies\Microsoft\Windows\WindowsUpdate' 
 ValueName = 'TargetGroup'
 ValueData = 'PSConfEU2017'
 ValueType = 'String'
 Ensure = 'Present'
 }

Registry TargetMode
 {
 Key = 'HKLM:\Software\Policies\Microsoft\Windows\WindowsUpdate' 
 ValueName = 'TargetGroupEnabled'
 ValueData = 1
 ValueType = 'DWord'
 Ensure = 'Present'
 }
 
 Registry InstallOption
 {
 Key = 'HKLM:\Software\Policies\Microsoft\Windows\WindowsUpdate\AU' 
 ValueName = 'AUOptions'
 ValueData = 3 #(2 = Notify before download. 3 = Automatically download and notify of installation. 4 = Automatic download and scheduled installation. (Only valid if values exist for ScheduledInstallDay and ScheduledInstallTime.) 5 = Automatic Updates is required, but end users can configure it.)
 ValueType = 'DWord'
 Ensure = 'Present'
 }
 
 Registry DetectionFrequencyHours
 {
 Key = 'HKLM:\Software\Policies\Microsoft\Windows\WindowsUpdate\AU' 
 ValueName = 'DetectionFrequencyEnabled'
 ValueData = 2 # (hours frequency)
 ValueType = 'DWord'
 Ensure = 'Present'
 } 
 
 Registry Installday
 {
 Key = 'HKLM:\Software\Policies\Microsoft\Windows\WindowsUpdate\AU' 
 ValueName = 'ScheduledInstallDay'
 ValueData = 0 # 0-7 (where 0 is every day, 1 is Sunday)
 ValueType = 'DWord'
 Ensure = 'Present'
 } 
 }
}

# Nodeliste fuer Konfig Generierung
$Nodes = @('Nano01.legendary.local')

#Erstellen der Konfiguration
WSUSAutoDL -ConfigurationData $ConfigurationData -OutputPath C:\DSC\WSUS -NodeName $Nodes

# Verteilen der Konfiguration
Start-DscConfiguration -Path C:\DSC\WSUS -Wait -Force -Verbose

Enter-PSSession -ComputerName Nano01
Get-Item -Path 'HKLM:\Software\Policies\Microsoft\Windows\WindowsUpdate\AU'