## Docker setup on Server 

# Enable Windows feature // REQUIRED
Get-WindowsFeature -Name *container* | Install-WindowsFeature -Restart
Get-Module -Name *container*
Get-Command -Module Containers

# Get docker // REQUIRED
Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force
Set-PSRepository -name PSGallery -InstallationPolicy Trusted -InformationAction SilentlyContinue
Install-Module -Name DockerMsftProvider -Repository PSGallery -Force
Install-Package -Name docker -ProviderName DockerMsftProvider -Force
Restart-Computer

# Get (preview) container Cmdlets // OPTIONAL
# Register-PSRepository -Name DockerPS-Dev -SourceLocation 'https://ci.appveyor.com/nuget/docker-powershell-dev'
# Find-Module -Name Docker
# Install-Module -Name Docker -Repository DockerPS-Dev -Scope AllUsers -Force

# Work with containers
# a: WS 2016 NANO
docker search microsoft/nanoserver 
docker pull microsoft/nanoserver 

# b: WS 2016 Core
docker search microsoft/windowsservercore
docker pull microsoft/windowsservercore

# c: Linux
docker search alpine -f "is-official=true"
docker pull alpine

# Run "Windows Server Container"
docker run -it microsoft/nanoserver powershell

# Isolation
docker info | Select-String -Pattern 'Isolation'
docker run -it --isolation=hyperv microsoft/nanoserver powershell

# Add Hyper-V 
Get-WindowsFeature *hyper* | Install-WindowsFeature -Restart 

# Connect to container
Get-ComputeProcess | Select-Object Id, Isolation
Invoke-Command -ContainerId (Get-ComputeProcess).Id -ScriptBlock { hostname.exe } 
