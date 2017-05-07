#requires -Version 3 
<#	
        .NOTES
        ===========================================================================
        Created on:   	06.07.2016
        Created by:   	David das Neves
        Version:        0.5
        Project:        PSGUI
        Filename:       Open-XAMLDialog.ps1
        ===========================================================================
        .DESCRIPTION
        Function from the PSGUI module.
#> 
function Open-XAMLDialog
{
    <#
            .Synopsis
            Opens the dialog.
            .DESCRIPTION
            Loads dialog with xaml, events and code and shows it up as a dialog.
            .EXAMPLE
            Open-XAMLDialog "MyForm"
            .EXAMPLE
            Open-XAMLDialog -DialogPath "C:\Project PSGUI\PSGUI\PSGUI_Manager"
    #>
    [CmdletBinding()]
    Param
    (
        #Name of the dialog
        [Parameter(Mandatory = $false, Position = 0)]
        [Alias('Name')] 
        $DialogName,

        #Switch for creating only the global variables
        #which can be used to develop specific functions with intellisense.
        #It will be very helpful to generate the functions in the events.
        [switch]
        $OnlyCreateVariables = $false,

        #Switch for showing with show flag.
        #For use if a window open another window and shall be reactive.
        #Otherwise the window will be opened as Showdialog.
        [switch]
        $OpenWithOnlyShowFlag = $false,

        #Path of the dialog
        [Parameter(Mandatory = $false)]
        [Alias('Path')] 
        $DialogPath 
    )

    Begin
    {
        if ($DialogPath -and (-not $DialogName))
        {
            $DialogName = [System.IO.DirectoryInfo]::new($DialogPath).Name
        }    
    }
    Process
    {     
        if (-not $DialogPath -and (-not $DialogPath -or -not $(Get-Item $DialogPath)))
        {
        $PSGUIPath =''
        $DirectoriesToSearch = [Environment]::GetEnvironmentVariable('PSModulePath').Split(';')
        foreach ($dir in $DirectoriesToSearch )
        {
            $PSGUIPath = Get-ChildItem -Path $dir -Filter 'PSGUI' -Recurse
            if ($PSGUIPath)
            {
                $PSGUIPath = Get-ChildItem -Path ($PSGUIPath.FullName) -Filter 'dialogs' -Recurse
                break
            }
        }
        $AllDialogsPaths = Get-ChildItem -Path ($PSGUIPath.FullName) -Directory   
        foreach ($OneDialogPath in $AllDialogsPaths)
            {
                if ($DialogName -in (Get-ChildItem -Path $($OneDialogPath.FullName)).Name)
                {
                    $DialogPath = [System.IO.Path]::Combine($OneDialogPath.FullName, $DialogName)
                    break
                }
            }        
        }

        #Loads XAML
        Initialize-XAMLDialog -XAMLPath ([System.IO.Path]::Combine($DialogPath,"$DialogName.xaml"))
                
        #Loads event and scriptcode        
        $scriptfile = ([System.IO.Path]::Combine($DialogPath,"$DialogName.ps1"))
        if (Get-Item -Path ($scriptfile))
        {
            . $scriptfile
        }    
        
        $additionalScriptfile = ([System.IO.Path]::Combine($DialogPath,$DialogName + '.psm1'))
        #Loads functions etc.
        if (Get-Item -Path $additionalScriptfile)
        {
            Import-Module $additionalScriptfile
        }
                  
        if (-not $OnlyCreateVariables)
        {
            if ($OpenWithOnlyShowFlag)
            {
                [void]$((Get-Variable -Name $DialogName).Value).Show()
            }
            else
            {
                [void]$((Get-Variable -Name $DialogName).Value).Dispatcher.InvokeAsync{
                    $((Get-Variable -Name $DialogName).Value).ShowDialog()
                }.Wait()
            }    
        }        
    }
    End
    {
    }
}
