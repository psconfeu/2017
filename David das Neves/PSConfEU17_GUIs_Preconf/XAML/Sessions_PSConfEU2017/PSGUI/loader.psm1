<#	
        .NOTES
        ===========================================================================
        Created on:   	06.07.2016
        Created by:   	David das Neves
        Version:        0.5
        Project:        PSGUI
        Filename:       loader.psm1
        ===========================================================================
        .DESCRIPTION
        Loading functions for PSGUI module.
#> 

. $PSScriptRoot\Get-XAMLDialogsByCategory.ps1
. $PSScriptRoot\Initialize-XAMLDialog.ps1
. $PSScriptRoot\New-XAMLDialog.ps1
. $PSScriptRoot\Rename-XAMLDialog.ps1
. $PSScriptRoot\Open-XAMLDialog.ps1
. $PSScriptRoot\Install-PSGUIModule.ps1
. $PSScriptRoot\Start-PSGUIManager.ps1
. $PSScriptRoot\New-LinkForPSGUIManager.ps1
. $PSScriptRoot\Export-Dialogs.ps1