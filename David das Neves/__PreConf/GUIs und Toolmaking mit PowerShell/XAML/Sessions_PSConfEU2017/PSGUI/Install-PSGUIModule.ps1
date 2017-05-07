#requires -Version 2 
<#	
        .NOTES
        ===========================================================================
        Created on:   	06.07.2016
        Created by:   	David das Neves
        Version:        0.5
        Project:        PSGUI
        Filename:       Install-PSGUIModule.ps1
        ===========================================================================
        .DESCRIPTION
        Function from the PSGUI module.
#> 
function Install-PSGUIModule
{
    <#
            .SYNOPSIS
            Re/Installs the Module PSGUI
            .EXAMPLE
            Install-PSGUIModule
    #>
    [CmdletBinding()]
    Param
    (
        #Flag to cleanup previous data
        [switch]
        $CleanUpPreviousData = $false
    )    

    if ((Test-Path -Path "$env:UserProfile\Documents\WindowsPowerShell\Modules\PSGUI") -and $CleanUpPreviousData)
    {
        Remove-Module -Name PSGUI -Verbose -ErrorAction SilentlyContinue
        Remove-Item -Path "$env:UserProfile\Documents\WindowsPowerShell\Modules\PSGUI" -Recurse -Verbose
    } 
    else
    {
        if (Get-Module -Name PSGUI)
        {
            Remove-Module -Name PSGUI -Verbose -ErrorAction SilentlyContinue
        }
    }
    
    Copy-Item -Path '.\Project PSGUI\PSGUI\'  -Destination "$env:UserProfile\Documents\WindowsPowerShell\Modules\PSGUI" -Recurse -Force
    Import-Module -Name PSGUI -Verbose
}
