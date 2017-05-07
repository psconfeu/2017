#requires -Version 1
<#	
        .NOTES
        ===========================================================================
        Created on:   	06.07.2016
        Created by:   	David das Neves
        Version:        0.59
        Project:        PSGUI
        Filename:       New-LinkForGUIManager.ps1
        ===========================================================================
        .DESCRIPTION
        Function from the PSGUI module.
#> 
function New-LinkForGUIManager
{
    <#
            .SYNOPSIS
            Creates the link for the PSGUIManager
            .EXAMPLE
            New-LinkForGUIManager
    #>
    Write-Host -Object 'Creating Hyperlink'
    $TargetFile = "$env:SystemRoot\System32\WindowsPowerShell\v1.0\powershell.exe" 
    $GUIManagerPath = (Get-ChildItem -Path  "$env:UserProfile\Documents\WindowsPowerShell\Modules\PSGUI\" -Filter 'PSGUI_Manager'-Recurse)[0].FullName
    $ShortcutFile = "$env:UserProfile\Desktop\PSGUI-Manager.lnk"
    $WScriptShell = New-Object -ComObject WScript.Shell
    $Shortcut = $WScriptShell.CreateShortcut($ShortcutFile)
    $Shortcut.WorkingDirectory = $GUIManagerPath
    # WindowStyle 1= normal, 3= maximized, 7=minimized
    $Shortcut.WindowStyle = 7
    # Powershell window is hidden.
    #$Shortcut.Arguments=' -windowstyle hidden "' + $GUIManagerPath + 'ExecByShortcut.ps1"'
    $Shortcut.Arguments = ' -windowstyle hidden "Start-PSGUIManager"'
    $Shortcut.TargetPath = $TargetFile
    $Shortcut.IconLocation = $GUIManagerPath + '\Resources\PSGUI_Manager.ico'
    $Shortcut.Save()
    Write-Host -Object 'Hyperlink created.' -ForegroundColor Green
}
