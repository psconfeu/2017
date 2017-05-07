#requires -Version 2
<#	
        .NOTES
        ===========================================================================
        Created on:   	29.07.2016
        Created by:   	David das Neves
        Version:        0.53
        Project:        PSGUI
        Filename:       New-XAMLDialog.ps1
        ===========================================================================
        .DESCRIPTION
        Function from the PSGUI module.
#> 
function New-XAMLDialog
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
        $DialogPath,

        #Name of the internal dialogpath
        [Parameter(Mandatory = $false, Position = 3)]
        $Internal_DialogFolder 
    )

    Begin
    {
    }
    Process
    {
        if (-not (Test-Path -Path "$DialogPath\$DialogName"))
        {
            $PSGUIPath = ''
            $DirectoriesToSearch = [Environment]::GetEnvironmentVariable('PSModulePath').Split(';')
            foreach ($dir in $DirectoriesToSearch )
            {
                $Internal_DialogFolder = Get-ChildItem -Path $dir -Filter 'Internal' -Recurse
                if ($Internal_DialogFolder)
                {
                    Copy-Item -Path "$($Internal_DialogFolder.FullName)\Internal_Clean" -Destination "$DialogPath\$DialogName" -Recurse
                    Get-ChildItem -Path "$DialogPath\$DialogName" -Recurse -Include '*.ps*1', '*.xaml' | Rename-Item -NewName {
                        $_.Name -replace 'Internal_Clean', $DialogName
                    }
                    break
                }
            }
        } 
    }
    End
    {
    }
}
