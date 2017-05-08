#Install the Nuget Package Provider to work with the PSGallery.
Install-PackageProvider Nuget -ForceBootstrap -Force

#Ensure the Repository is trusted.
Set-PSRepository -Name PSGallery -InstallationPolicy Trusted

#Install Any modules we need for our DSC Configuration and/or testing.
Install-Module Pester, PsScriptAnalyzer, cChoco, xPSDesiredStateConfiguration -Force

#Copy the Installed Modules into the Output path for later on when we zip the contents
Copy-Item 'C:\Program Files\WindowsPowerShell\Modules\cChoco','C:\Program Files\WindowsPowerShell\Modules\xPSDesiredStateConfiguration' -Recurse -Destination $ProjectRoot
