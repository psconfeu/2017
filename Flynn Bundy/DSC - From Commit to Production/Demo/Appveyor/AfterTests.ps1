#Import the Configuration Script
Import-Module '.\developers-world\demo\Generation\Mof\ConfigurationScript.ps1'

#Call The Configuration Script passing in our Configuration Data
Main -OutputPath $ProjectRoot -ConfigurationData '.\developers-world\demo\ConfigurationData\ConfigurationData.psd1' -BeertimeAPIKey $Env:BeertimeAPIKey

#Create a Zip from the Mof output (Include Modules)
Get-Item -Path "$ProjectRoot\developers-world\demo\Cloudformation\EC2Userdata.ps1",
               "$ProjectRoot\beertime.mof",
               "$ProjectRoot\cChoco",
               "$ProjectRoot\xPSDesiredStateConfiguration" | Compress-Archive -DestinationPath $ProjectRoot\Mofs.zip

#Publish zip as artifact
Push-AppveyorArtifact $ProjectRoot\Mofs.zip -Verbose
