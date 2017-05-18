@{

    # Script module or binary module file associated with this manifest.
    RootModule = 'FishTank.psm1'

    # Version number of this module.
    ModuleVersion = '0.1.0'

    # ID used to uniquely identify this module
    GUID = '60feca06-2301-45a0-a28a-bd28adfbfeb9'

    # Author of this module
    Author = 'Staffan Gustafsson'

    # Company or vendor of this module
    CompanyName = 'PowerCode Consulting AB'

    # Copyright statement for this module
    Copyright = '(c) 2017 Staffan. All rights reserved.'

    # Description of the functionality provided by this module
    Description = 'Management tools for fishtanks'

    # Minimum version of the Windows PowerShell engine required by this module
    PowerShellVersion = '5.0.0'

    # Format files (.ps1xml) to be loaded when importing this module
    FormatsToProcess = @('FishTank.format.ps1xml')


    # Functions to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no functions to export.
    FunctionsToExport = @(
        'Import-FishTank'
        'Export-FishTank'
        'Add-FishTank'
        'Remove-FishTank'
        'Clear-FishTank'
        'Get-FishTank'
        'Get-FishTankModel'
    )

    # Cmdlets to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no cmdlets to export.
    CmdletsToExport = ''

    # Variables to export from this module
    VariablesToExport = ''

    # Aliases to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no aliases to export.
    AliasesToExport = @(
        'gft'
        'clft'
    )

    # List of all files packaged with this module
    # FileList = @()

    # Private data to pass to the module specified in RootModule/ModuleToProcess. This may also contain a PSData hashtable with additional module metadata used by PowerShell.
    PrivateData = @{

        PSData = @{

            # Tags applied to this module. These help with module discovery in online galleries.
            Tags = @('Fishtank', 'Example', 'Module', 'Design')

            # A URL to the license for this module.
            LicenseUri = 'https://github.com/powercode/PSConfEU/blob/master/LICENSE'

            # A URL to the main website for this project.
            ProjectUri = 'https://github.com/powercode/PSConfEU/tree/master/ProfModule2017/FishTank'


        } # End of PSData hashtable

    } # End of PrivateData hashtable
}


