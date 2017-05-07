#requires -Version 2
<#	
        .NOTES
        ===========================================================================
        Created on:   	06.07.2016
        Created by:   	David das Neves
        Version:        0.5
        Project:        PSGUI
        Filename:       Export-Dialogs.ps1
        ===========================================================================
        .DESCRIPTION
        Function from the PSGUI module.
#> 
function Export-Dialogs
{
    <#
            .Synopsis
            Creates a new dialog.
            .DESCRIPTION
            New dialog with standard xaml.
            .EXAMPLE
            Create-XAMLDialog
            .EXAMPLE
            Create-XAMLDialog "MyForm"
    #>
    [CmdletBinding()]
    Param
    (
        #Name of the dialog
        [Parameter(Mandatory = $false, Position = 1)]
        [Alias('Name')] 
        $DialogName = 'Clean',

        #Name of the dialog
        [Parameter(Mandatory = $false, Position = 2)]
        [Alias('Path')] 
        $DialogPath = $Internal_DialogFolder
    )

    Begin
    {
    }
    Process
    {
        if (-not (Test-Path -Path "$DialogPath\$DialogName"))
        {
            Copy-Item -Path "$Internal_DialogFolder\Internal_Clean" -Destination "$DialogPath\$DialogName" -Recurse
            Get-ChildItem -Path "$DialogPath\$DialogName" -Recurse -Include '*.ps*1', '*.xaml' | Rename-Item -NewName {
                $_.Name -replace 'Internal_Clean', $DialogName
            }            
        }
    }
    End
    {
    }
}
