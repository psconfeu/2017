# Nano Server
# PSconf EU 2017
# Script Help for PreConf Nano Server and Container

# Quick

# Step 1 - Mount ISO Drive and Copy Content

$destinationDir = "C:\NanoServer"

$mounted = Mount-DiskImage -ImagePath "C:\Downloads\en_windows_server_2016_x64_dvd_9718492.iso"
$driveLetter = ($mounted | Get-Volume).DriveLetter
$sourcePath = $driveLetter + ":\NanoServer"

robocopy "$sourcePath" "$destinationDir" "/MIR" #Copy Files with robocopy, more efficient than Copy-Item

# More Advanced Example Mount

$ImagePath= "C:\Downloads\en_windows_server_2016_x64_dvd_9718492.iso"
$ISODrive = (Get-DiskImage -ImagePath $ImagePath | Get-Volume).DriveLetter
IF (!$ISODrive) {
Mount-DiskImage -ImagePath $ImagePath -StorageType ISO
}
$ISODrive = (Get-DiskImage -ImagePath $ImagePath | Get-Volume).DriveLetter
$ISODrive = $ISODrive + ":\"

# Step 2 - Mount Module

Import-Module ($destinationDir + "\NanoServerImageGenerator\NanoServerImageGenerator.psm1")

# Step 3 - Create BasePath - Working Dir

$BasePath = "C:\Nano"

if(!$BasePath){
    New-Item -Path $BasePath -ItemType Directory
} else{
    Write-Host "Der Pfad ""$BasePath"" existiert bereits"
}

# Step 4 - Let's see the new cmdlets

Get-Command –module NanoServerImageGenerator

# Step 5 Create a new Nano-Server-Image

# Quick

# Step 5.1 -> Create Nano Server Image VHD with IP-Address

Set-Location $destinationDir
New-NanoServerImage -MediaPath .\ -BasePath C:\Nano -TargetPath .\Images\NanoVM01.vhd -MaxSize 20GB -DeploymentType Guest -Packages $NanoPackages -Edition Datacenter -ComputerName "Nano01" -InterfaceNameOrIndex Ethernet -Ipv4Address "192.168.1.177" -Ipv4SubnetMask "255.255.255.0" -Ipv4Gateway "192.168.1.1" -Ipv4Dns "192.168.1.50"


# Better Step 5.1

$VHDDest = ".\Images\NanoVM01.vhdx"
$MaxSize = 20GB
$Edition = "Datacenter"
$DeploymentType = "Guest"
# $DriverPath = ".\Drivers" -> -DriverPath $DriverPath
$MediaPath = "C:\"
# $BasePath -> bei uns vorher definiert
$ComputerName = "Nano01"
$DomainName = "legendary.local"


$NanoPackages = "Microsoft-NanoServer-Storage-Package",
"Microsoft-NanoServer-Compute-Package",
"Microsoft-NanoServer-DCB-Package",
"Microsoft-NanoServer-FailoverCluster-Package",
"Microsoft-NanoServer-DSC-Package",
"Microsoft-NanoServer-OEM-Drivers-Package"

 
# IP Configuration
$Ipv4Address = "192.168.1.177"
$Ipv4SubnetMask = "255.255.0.0"
$Ipv4Gateway = "192.168.1.1"
$Ipv4Dns = "192.168.1.50"

# If needed implement some updates -> add "-ServicingPackagePath $ServicingPackagePath"
# $ServicingPackagePath = ".\updates\xx.cab", ".\Updates\xx.cab"

# If needed unnatend File  -> add "-UnattendPath $UnattendFile"
# $UnattendFile = ".\unattend\unattend.xml"
 
# Nano Image
New-NanoServerImage -MediaPath $MediaPath -BasePath $BasePath -TargetPath $VHDDest -DeploymentType $DeploymentType -Edition $Edition -Package $NanoPackages -MaxSize $MaxSize -ComputerName $ComputerName -DomainName $DomainName -InterfaceNameOrIndex Ethernet -Ipv4Address "192.168.1.177" -Ipv4SubnetMask "255.255.255.0" -Ipv4Gateway "192.168.1.1" -Ipv4Dns "192.168.1.50" -ReuseDomainNode -EnableRemoteManagementPort
 

# Step 6 -> Create VM

Copy-Item $destinationDir\Images\NanoVM01.vhdx -Destination C:\VMs
New-VM -Name NanoVM01 -BootDevice VHD -VHDPath C:\VMs\NanoVM01.vhdx -SwitchName External -Generation 2
Start-VM NanoVM01

############ Step 7.1 VM Management - PowerShell Direct ############

Enter-PSSession -VMName NanoVM01 #PSDirect

Get-Command -CommandType Cmdlet

############ Step 7.2  VM Management - Remote PSSession ############

Set-Item WSMan:\localhost\Client\TrustedHosts '192.168.1.177' -Concatenate –Force #Concatenate important not overwrite entries, add
Get-Item WSMan:\localhost\Client\TrustedHosts

Enter-PSSession -ComputerName 192.168.1.177 -Credential (Get-Credential)

############ Step 7.2 VM Management - PowerSHell CIM-Session (WMI) ############

$cimIp = "192.168.1.177"
$user = $DomainName + "\Administrator"
$cimSession = New-CimSession -Credential $user -ComputerName $cimip

Get-CimInstance -CimSession $cimSession -ClassName Win32_ComputerSystem | Format-List *
Get-CimInstance -CimSession $cimSession -Query "SELECT * from Win32_Process WHERE name LIKE '%'"  


# Step 8 Update Management running System

# Enter-PSSession -VMName NanoVM01 #PSDirect
$cim = New-CimInstance -CimSession $cimSession -Namespace root/Microsoft/Windows/WindowsUpdate -ClassName MSFT_WUOperationsSession
$msUpdates = Invoke-CimMethod -InputObject $cim -MethodName ScanForUpdates -Arguments @{SearchCriteria="IsInstalled=0";OnlineScan=$true}   

$installUpdates = Invoke-CimMethod -InputObject $cim -MethodName ApplyApplicableUpdates
Restart-Computer

############  Add Nano Server Roles ############

Get-WindowsFeature -ComputerName Nano01
Install-WindowsFeature -ComputerName Nano01 -Name Storage-Replica

############ Nano Server PackageProvider ############ #Help: https://github.com/OneGet/NanoServerPackage

Enter-PSSession -ComputerName 192.168.1.177 -Credential (Get-Credential)

# Download PowerShell Module
Save-Module -Path “$env:ProgramFiles\WindowsPowerShell\Modules” -Name NanoServerPackage -MinimumVersion 1.0.0.0

# Import PowerShell Module
Import-PackageProvider NanoServerPackage

# Find Nano Server Package
Find-NanoServerPackage
Find-Package -ProviderName NanoServerPackage -DisplayCulture

# Find Specific Nano Server Images
Find-NanoServerPackage *iis*

Install-NanoServerPackage -Name Microsoft-NanoServer-IIS-Package -Culture en-us -MinimumVersion 10.0.13393.0
Restart-Computer

# Get Installed Packages

Get-Package -ProviderName NanoServerPackage

# Get Installed Packages vhd
Get-Package -ProviderName NanoServerPackage -FromVhd C:\VMs\NanoServer-WIM-14300.1000.vhdx


####################### Install DSC on NanoServers #######################

#Install Nano Server Package Provider and DSC Package on Nodes
$Nodes = @('Nano01.legendary.local')
$Nodes | foreach {
 Invoke-Command -ComputerName $_ -ScriptBlock {
 Install-PackageProvider NanoServerPackage -Force
 Import-PackageProvider NanoServerPackage
 Install-package Microsoft-NanoServer-DSC-Package -ProviderName NanoServerPackage -Force
 }
}


########################################################## Break before Container ######################################################


############################# Vorbereiten Host ################################

#Install Hyper-V
#Install-WindowsFeature Hyper-V -IncludeAllSubFeature -IncludeManagementTools -Restart

#Install-Container
#Install-WindowsFeature Containers -IncludeAllSubFeature -IncludeManagementTools -Restart

#Ueberpruefen Prerequisites
Get-WindowsFeature -Name Hyper-V
Get-WindowsFeature -Name Containers

# Nach TP5 Docker Management
# Unstable preRelease PowerShell Docker implementation
# Register-PSRepository -Name DockerPS-Dev -SourceLocation https://ci.appveyor.com/nuget/docker-powershell-dev
# Install-Module -Name Docker -Repository DockerPS-Dev -Scope CurrentUser -AllowClobber

Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force
Install-Module -Name DockerMsftProvider -Force
Install-Package -Name docker -ProviderName DockerMsftProvider -Force
Restart-Computer -Force

# docker befehle anschauen

docker help

# Images suchen mit Docker
docker search Microsoft

# Runterladen NanoServer Image
docker pull microsoft/nanoserver
# Runterladen ServerCore Image
docker pull microsoft/windowsservercore
# Runterladen NanoServer Image mit IIS
docker pull microsoft/iis:nanoserver

# FireWall Ports  für externes Docker Management Zulassen
netsh advfirewall firewall add rule name="docker engine" dir=in action=allow protocol=TCP localport=2375

# Konfiguration Docker Service damit er auf Port 2375 von Extern hört
Stop-Service docker
dockerd --unregister-service
dockerd -H npipe:// -H 0.0.0.0:2375 --register-service
Start-Service docker

# Docker Version überprüfen

docker version

# Erstellen erster Windows-Container
docker run -d microsoft/nanoserver cmd.exe
docker ps -a

# Erstellen erster HyperV-Container
docker run -d --isolation=hyperv microsoft/nanoserver cmd

################################################# Mit Containern Spielen #################################################


#Container Images Anzeigen
docker images

#Erste Applikation erstellen
Enter-PSSession -ContainerName IISWorker01 -RunAsAdministrator

#Entfernen der Default-Site
del C:\inetpub\wwwroot\iisstart.htm

#Erstellen einer neuen Website
"Hello World" > C:\inetpub\wwwroot\index.html

#Da war doch noch was, die containerdemo file...
Get-ChildItem C:\

#Session Verlassen
Exit-PSSession

#Stopen des Worker IIS Containers
Stop-Container -Name IISWorker01

#Entfernen des Worker IIS Containers
Remove-Container -Name IISWorker01 -Force

#Entfernen des Manipulierten "Images"
Remove-ContainerImage -Name WindowsServerCoreIIS -Force -WhatIf



################ Hyper-V Container ################

#Erstellen eines Hyper-V  Containers
$hvcontainer01 = New-Container -Name HYPVCON01 -ContainerImageName NanoServer -SwitchName "NATSwitch01" -RuntimeType HyperV



################# Docker ##################

docker run -it --isolation=hyperv 646d6317b02f cmd




############################ Docker Ressource Management ##########################
docker run -it --cpu-shares 2 --name dockerdemo windowsservercore cmd
