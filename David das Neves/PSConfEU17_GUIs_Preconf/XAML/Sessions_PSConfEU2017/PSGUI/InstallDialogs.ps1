#requires -Version 2 -Modules PSGUI
<#	
        .NOTES
        ===========================================================================
        Created on:   	06.07.2016
        Created by:   	David das Neves
        Version:        0.5
        Project:        PSGUI
        Filename:       InstallDialogs.ps1
        ===========================================================================
        .DESCRIPTION
        Installs PSGUI-Module and PSGUI-Manager.
#> 

Write-Host -Object '==========================================================================='
Write-Host -Object 'Starting installation.'

$DialogPath = "$env:UserProfile\Documents\WindowsPowerShell\Modules\PSGUI\Dialogs\"

Set-Location -Path $PSScriptRoot\..\

#region install module
. .\PSGUI\Install-PSGUIModule.ps1
Install-PSGUIModule
#endregion

#region create shortcut on user-desktop
$newDialogNames = Get-ChildItem -Path $DialogPath |
Select-Object -ExpandProperty Name |
Where-Object -FilterScript {
    ($_ -notlike 'Example_*') -and ($_ -notlike 'Internal_*')
}
foreach ($dialogName in $newDialogNames)
{
    $TargetFile = "$env:SystemRoot\System32\WindowsPowerShell\v1.0\powershell.exe" 
    $GUIManagerPath = "$env:UserProfile\Documents\WindowsPowerShell\PSGUI_Manager\"
    $ShortcutFile = "$env:UserProfile\Desktop\$dialogName.lnk"
    $WScriptShell = New-Object -ComObject WScript.Shell
    $Shortcut = $WScriptShell.CreateShortcut($ShortcutFile)
    $Shortcut.WorkingDirectory = $GUIManagerPath
    # WindowStyle 1= normal, 3= maximized, 7=minimized
    $Shortcut.WindowStyle = 7
    # Powershell window is hidden.
    "Import-Module PSGUI;Open-XAMLDialog -DialogName $dialogName -DialogPath $DialogPath$dialogName';"
    $Shortcut.Arguments = ' -windowstyle hidden "' + "Import-Module PSGUI;Open-XAMLDialog -DialogName $dialogName -DialogPath $DialogPath$dialogName" + '"'
    $Shortcut.TargetPath = $TargetFile
    if (Test-Path -Path "$DialogPath\$dialogName\Resources\$dialogName.ico'")
    {
        $Shortcut.IconLocation = $dialogName + 'Resources\$dialogName.ico'
    }        
    $Shortcut.Save()
}
#endregion

Write-Host -Object 'Installation complete.'
Write-Host -Object '==========================================================================='

