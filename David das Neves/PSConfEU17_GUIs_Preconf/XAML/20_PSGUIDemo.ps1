#Save-Module PSGUI -Path ($env:PSModulePath).Split(';')[0]

Get-Command -Module PSGUI


New-LinkForGUIManager

Start-PSGUIManager





















Open-XAMLDialog -DialogName '05_Bindings2' 


Open-XAMLDialog -Path C:\Users\dadasnev\Documents\WindowsPowerShell\Modules\PSGUI\0.58\Dialogs\Examples\MouseTracker


Open-XAMLDialog -DialogName 'Internal_UserInput'
$Returnvalue_Internal_UserInput

































Publish-Module -Name PSGUI -NuGetApiKey a94c41dc-332a-43d1-9663-a287ece58b2e

