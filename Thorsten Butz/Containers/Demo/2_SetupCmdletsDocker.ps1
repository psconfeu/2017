## PoSh Cmdlets for docker 

# Container cmdlets, modules? 
Get-Module -Name *container* -ListAvailable
Get-Command -Name *container*

# PSGallery? 
Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force
Set-PSRepository -name PSGallery -InstallationPolicy Trusted -InformationAction SilentlyContinue
Get-PSRepository
Find-Module -Name *container*

# Docker cmdlets: "v0.1.0 Alpha preview release of Docker PowerShell." from August 2016
# https://github.com/Microsoft/Docker-PowerShell/releases
# Available through "appveyor" repo

Register-PSRepository -Name DockerPS-Dev -SourceLocation https://ci.appveyor.com/nuget/docker-powershell-dev
Find-Module -Name Docker
Install-Module -Name Docker -Repository DockerPS-Dev -Scope AllUsers -Force
Update-Module -Name Docker # Later
Get-Module docker -ListAvailable 
Get-Command -Module docker 
(Get-Command -Module docker).count

# Auto completion (by Sam Neirinck)
Find-Module posh-docker | Install-Module
Import-Module posh-docker 

<# 
    Manual setup:
 
    $uri = 'https://github.com/Microsoft/Docker-PowerShell/releases/download/v0.1.0/Docker.0.1.0.zip'
    $zip = $uri.Split('/')[-1] 
    iwr -UseBasicParsing -Uri $uri  -OutFile $zip
    Expand-Archive -Path $zip -DestinationPath .\Modules\Docker\
    Import-Module .\Modules\Docker

#>