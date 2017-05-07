#requires -Version 3
<#	
        .NOTES
        ===========================================================================
        Created on:   	06.07.2016
        Created by:   	David das Neves
        Version:        0.5
        Project:        PSGUI
        Filename:       Initialize-XAMLDialog.ps1
        ===========================================================================
        .DESCRIPTION
        Function from the PSGUI module.
#> 
function Initialize-XAMLDialog
{
    <#
            .Synopsis
            XAML-Loader
            .DESCRIPTION
            Loads the xaml file and sets global variables for all elements.
            .EXAMPLE
            Initialize-XAMLDialog "..\Dialogs\MyForm.xaml"
            .Notes
            - namespace-class removed and namespace added
            - absolute and relative paths
            - creating variables for each object
    #>
    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory = $True, Position = 1)]
        [string]$XAMLPath,

        #If enabled all objects will be named $Formname_Objectname
        #Example: $PSGUI_lbDialogs
        #If not it would look like
        #Example: $lbDialogs
        #By using namespaces the possibility that a variable will be overwritten is mitigated.
        [switch]
        $UseFormNameAsNamespace = $True
    )
    Begin
    { 
        #Add WPF assemblies
        try
        {
            Add-Type -AssemblyName PresentationCore, PresentationFramework
        } 
        catch 
        {
            Throw 'Failed to load Windows Presentation Framework assemblies.'
        }

        #Loads xml previously in container
        $preload = Get-Content -Path $XAMLPath

        #Catch all relative paths
        $directory = (Get-Item $XAMLPath).Directory.FullName        
        $preload = $preload -replace '(=".\\)', $("=`"" + $directory + '\')

        #Catch all absolute paths        
        $matchesFile = [regex]::Matches($preload,'(=")[a-z,A-Z]{1}[:][a-z,A-Z,0-9 \\_.-]*["]')
        foreach ($matchF in $matchesFile)
        {
            $FileFullName = ($matchF.Value).Replace('"','').Replace('=','')
            if (-not (Test-Path $FileFullName))
            {
                $fileName = ($FileFullName.Split('\'))[-1]
                $filesInDirectory = Get-ChildItem $directory -File -Filter "$fileName" -Recurse
                if ($filesInDirectory.Count -gt 0)
                {
                    #Replacing path with the actual one 
                    $preload = $preload.Replace($matchF.Value,$("=`"" + $filesInDirectory[0].FullName + "`""))
                }
            }            
        }

        #Xaml-file is load as xml.
        [xml]$xmlWPF = $preload

        #Retrieve namespace
        $matchesFile = [regex]::Matches($preload,' [a-z,A-Z,0-9](:Class)')

        if ($matchesFile.Count -eq 1)
        {
            #Remove class attribute            
            $namespaceName = ($matchesFile.Value).Split(':')[0]
            $xmlWPF.Window.RemoveAttribute($namespaceName + ':Class')
            $xmlWPF.Window.RemoveAttribute('x:Class')
        } 
    }
    Process
    {       
        if (Test-Path -Path $XAMLPath)
        {
            #Retrieves the file- and dialogname by the filename of the xaml-file.
            #Therefore this name must be consistent at folder and file-level.
            $fileName = ((Get-Item -Path $XAMLPath).Name).Split('.')[0]
 
            #Create the XAML reader using a new XML node reader
            Set-Variable -Name $($fileName) -Value ([Windows.Markup.XamlReader]::Load((New-Object System.Xml.XmlNodeReader $xmlWPF))) -Scope Global

            #Getting and setting the namespace of the xaml file
            $ns = New-Object -TypeName System.Xml.XmlNamespaceManager -ArgumentList ($xmlWPF.NameTable)
            $ns.AddNamespace("$namespaceName", $xmlWPF.DocumentElement.NamespaceURI)

            #Retrieves the nodes.
            $nodes = $xmlWPF.SelectNodes('//*', $ns)

            #Create hooks to each named object in the XAML with using the namespace
            foreach ($nameOfNode in $nodes.Name)
            {
                #TODO do class instead of bunch of variables?
                #Compatiblity only with PS 5.0 >
                                
                $valueOfItem=((Get-Variable -Name $filename).Value).FindName("$nameOfNode")

                if ($valueOfItem -ne $null)
                {
                    if ($UseFormNameAsNamespace)
                    {
                        Set-Variable -Name "$((Get-Variable -Name $filename).Name)_$nameOfNode" -Value $((Get-Variable -Name $filename).Value).FindName("$nameOfNode") -Scope Global
                    }
                    else 
                    {
                        Set-Variable -Name $nameOfNode -Value $((Get-Variable -Name $filename).Value).FindName("$nameOfNode") -Scope Global
                    }             
                }
            }
        }
        else
        {
            Throw ('"XAML-Path could not be resolved: ' + $XAMLPath)
        }
    }
    End
    {
    }
}
