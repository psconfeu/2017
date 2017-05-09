function Get-BriefHelp {
    param(
        $Name
    )
    (Get-Help $Name).Parameters.Parameter |
    Select-Object Name,@{
        n= 'Help'
        e= {-join $_.Description.Text}
    }
}

# Display the object based nature of PowerShell help
Get-Help Get-Help | Get-Member
(Get-Help Get-Help).Parameters
(Get-Help Get-Help).Parameters.Parameter
(Get-Help Get-Help).Parameters.Parameter.Name
(Get-Help Get-Help).Parameters.Parameter[0].Description.Text

# Show examples of Get-BriefHelp on existing cmdlets
Get-BriefHelp Get-ChildItem
Get-BriefHelp Rename-Computer
Get-BriefHelp New-VM

# Autofill using #
#1
#2
#3

# Search back CTRL R
# <CTRL> R	

# Console tricks, open current path
ii .

# Display default path of PSReadline history
(Get-PSReadlineOption).HistorySavePath

# Open PSReadline history file
ii (Get-PSReadlineOption).HistorySavePath

# PowerShell Incognito mode
Get-Module PSReadLine
Remove-Module PSReadLine -Force

# Remove profile loading notification
powershell.exe -nologo

# PowerShell command vs file
param (
    [string[]] $Array,
    [int]      $Integer
)
'Array contains  : {0}' -f ($Array -join ';')
'Array type is   : {0}' -f $Array.GetType().ToString()
'Array count     : {0}' -f $Array.Count
'Integer contains: {0}' -f $Integer
'Integer type is : {0}' -f $Integer.GetType().ToString()


powershell -noprofile -file .\Test-Script.ps1 stuff 123

powershell -noprofile -file .\Test-Script.ps1 stuff morestuff evenmore 123

powershell -noprofile -file .\Test-Script.ps1 'stuff','morestuff','evenmore' 123

powershell -noprofile -file .\Test-Script.ps1 @('stuff','morestuff','evenmore') 123

powershell -noprofile -command "C:\Temp\Test-Script.ps1 -Array stuff, morestuff, evenmore -Integer 123"

# Bonus 64bit
c:\windows\system32\WindowsPowerShell\v1.0\powershell.exe -noprofile -command "[Environment]::Is64BitProcess"
c:\windows\syswow64\WindowsPowerShell\v1.0\powershell.exe -noprofile -command "[Environment]::Is64BitProcess"

# Single threaded vs multithreaded
powershell.exe -Sta
powershell.exe -Mta

# Install Module Project Oxford
Install-Module ProjectOxford

Import-Module 'C:\PSConfEU\Sessions\PowerShell Uncensored\ProjectOxford\ProjectOxford.psm1'

# Setup API keys
$env:MS_ComputerVision_API_key = 'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
$env:MS_SpellCheck_API_key     = 'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
$env:MS_WebLM_API_key          = 'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
$env:MS_TextAnalytics_API_key  = 'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
$env:MS_BingSearch_API_key     = 'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
$env:MS_Emotion_API_key        = 'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'

# Show images
Start-Process -FilePath 'http://www.psconf.eu/img/Erlebnsi-Zoo+Hannover_Yukon_Bay_c_Erlebnis-Zoo+Hannover_2.jpg'
Start-Process -FilePath 'http://www.psconf.eu/img/snover_laughing.jpg'
Start-Process -FilePath 'http://www.psconf.eu/img/speakers/RobSewell_200x300.jpg'

# Analyze images
Get-ImageAnalysis 'http://www.psconf.eu/img/Erlebnsi-Zoo+Hannover_Yukon_Bay_c_Erlebnis-Zoo+Hannover_2.jpg'
Import-CliXml .\Zoo.xml

Get-ImageAnalysis 'http://www.psconf.eu/img/snover_laughing.jpg'
Import-CliXml .\Snover.xml

Get-ImageAnalysis 'http://www.psconf.eu/img/speakers/RobSewell_200x300.jpg'
Import-Clixml .\Rob.xml

# Get the news
Get-News | Select-Object Topic -First 5
Import-CliXml .\News.xml

# Get Sentiment
'It is great to be here at PSConfEU' | Get-Sentiment
Import-CliXml .\Great.xml

'It is raining, I do not like the cold wet weather in Holland' | Get-Sentiment
Import-CliXml .\Holland.xml

Get-News | Select Topic,@{n='Sentiment';e={$_.Description | Get-Sentiment | Select -ExpandProperty OverallSentiment}}
Import-CliXml .\NewsSent.xml

# Download 
(iwr powershell.love -UseB).Content.SubString(1) | ConvertFrom-Json |select -first 1 | Foreach-Object {$_} |
Foreach-Object {
    Start-Sleep 1
    $_ | Select *,@{
        n = 'Positive'
        e = {
            [double]($_.Description | Get-Sentiment | Select-Object -ExpandProperty 'Positive %')
        }
    }
} | Out-GridView

# Test Adultcontent on Jaap's blog
(Invoke-WebRequest jaapbrasser.com).images.src | Get-Random -Count 5 | Foreach-Object {
    Test-AdultContent $_
}
Import-Clixml .\JaapContent.xml

# PowerShell Conference 2017 Most positive and most negative session descriptions
Import-Clixml .\Demo4Bottom2Top1.xml | Format-Table SpeakerList,Positive,Description -AutoSize

Import-Clixml .\Demo4Bottom2Top1.xml | Select-Object -Property SpeakerList,Positive,Description | Out-GridView

# http://www.bing.com/developers/s/APIBasics.html