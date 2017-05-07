#requires -Version 2
<#	
        .NOTES
        ===========================================================================
        Created on:   	06.07.2016
        Created by:   	David das Neves
        Version:        0.5
        Project:        PSGUI
        Filename:       Rename-XAMLDialog.ps1
        ===========================================================================
        .DESCRIPTION
        Function from the PSGUI module.
#> 
function Rename-XAMLDialog
{
    <#
            .Synopsis
            Renames a dialog and its containing functions.        
            .EXAMPLE
            Rename-XAMLDialog
    #>
    [CmdletBinding()]
    Param
    (
        #Name of the dialog
        [Parameter(Mandatory = $true, Position = 1)]
        [Alias('Name')] 
        $DialogName,

        #Name of the dialog
        [Parameter(Mandatory = $true, Position = 2)]
        [Alias('Path')] 
        $DialogPath,
         
        #new Name of the dialog
        [Parameter(Mandatory = $true, Position = 3)]
        [Alias('NewName')] 
        $NewDialogName
    )

    Begin
    {
    }
    Process
    {
        #replacing all matches in the files
        $content = Get-Content -Path "$DialogPath\$DialogName\$DialogName.ps1"
        $content = $content -replace "($DialogName)", $NewDialogName
        Set-Content -Value $content -Path "$DialogPath\$DialogName\$DialogName.ps1"

        $content = Get-Content -Path "$DialogPath\$DialogName\$DialogName.psm1"
        $content = $content -replace "($DialogName)", $NewDialogName
        Set-Content -Value $content -Path "$DialogPath\$DialogName\$DialogName.psm1"

        Get-ChildItem -Path "$DialogPath\$DialogName" -Recurse -Include '*.ps*1', '*.xaml'  | Rename-Item -NewName {
            $_.Name -replace $DialogName , $NewDialogName
        }  
        Get-Item -Path "$DialogPath\$DialogName" | Rename-Item -NewName {
            $_.Name -replace $DialogName , $NewDialogName
        }          
    }
    End
    {
    }
}
