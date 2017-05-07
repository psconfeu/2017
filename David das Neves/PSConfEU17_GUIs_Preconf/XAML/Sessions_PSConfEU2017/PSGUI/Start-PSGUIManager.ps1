#requires -Version 2 
<#	
        .NOTES
        ===========================================================================
        Created on:   	06.07.2016
        Created by:   	David das Neves
        Version:        0.5
        Project:        PSGUI
        Filename:       ExecByShortcut.ps1
        ===========================================================================
        .DESCRIPTION
        Starts the PSGUI_Manager. Used for starting with a shortcut.
#> 

function Start-PSGUIManager
{
    <#
            .SYNOPSIS
            Starts the PSGUI-Manager, which is included in the module PSGUI

            .EXAMPLE
            Start-PSGUIManager
    #>
    $PSGUIPath =''
    $DirectoriesToSearch = [Environment]::GetEnvironmentVariable('PSModulePath').Split(';')
    foreach ($dir in $DirectoriesToSearch )
    {
        $PSGUIPath = Get-ChildItem -Path $dir -Filter 'PSGUI_Manager' -Recurse
        if ($PSGUIPath)
        {
            Open-XAMLDialog -DialogName ('Internal_Start')
            Add-Type -Path "$($PSGUIPath.FullName)\Resources\ICSharpCode.AvalonEdit.dll"
            Add-Type -AssemblyName System.Windows.Forms
            Open-XAMLDialog -DialogName 'PSGUI_Manager' -DialogPath ($PSGUIPath.FullName)
            break
        }
    }
    if (-not $PSGUIPath)
    {
        Write-Error 'MoudlePath not found - are you trying to start PSGUIManager in a other Usercontext?'
    }
   
}
