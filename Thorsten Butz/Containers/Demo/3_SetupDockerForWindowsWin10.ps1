#Requires -RunAsAdministrator

# Check Windows features
Get-WindowsOptionalFeature -Online -FeatureName '*Hyper*' | Select-Object FeatureName,State 
Get-WindowsOptionalFeature -Online -FeatureName 'Containers' | Select-Object FeatureName,State 

# Enable Hyper-V, Containers (on Windows 10)
Enable-WindowsOptionalFeature -online -FeatureName 'Microsoft-Hyper-V-All','Containers' -NoRestart

# Get docker (for Windows 10)
Invoke-WebRequest -Uri 'https://download.docker.com/win/stable/InstallDocker.msi' -OutFile 'c:\InstallDocker.msi'
msiexec.exe /i C:\InstallDocker.msi /passive /forcerestart