#requires -Version 3
<#	
        .NOTES
        ===========================================================================
        Created on:   	06.07.2016
        Created by:   	David das Neves
        Version:        0.5
        Project:        PSGUI
        Filename:       Get-XAMLDialogsByCategory.ps1
        ===========================================================================
        .DESCRIPTION
        Function from the PSGUI module.
#> 
function Get-XAMLDialogsByCategory
{
    <#
            .Synopsis
            Gets the XAML dialogs defined by a category.      
            .EXAMPLE
            Get-XAMLDialogsByCategory
    #>
    [CmdletBinding()]
    Param
    (
        #Name of the dialog
        [Parameter(Mandatory = $true, Position = 0)]
        $Category
    )
    Begin
    {
    }
    Process
    {
        $dialogFolderToSearch = "$($Category)_DialogFolder"
        Set-Variable -Name $dialogFolderToSearch -Value "$env:UserProfile\Documents\WindowsPowerShell\Modules\PSGUI\Dialogs\$Category"
        
        return (Get-ChildItem -Path (Get-Variable -Name $dialogFolderToSearch).Value -Directory).Name
    }
    End
    {
    }
}
