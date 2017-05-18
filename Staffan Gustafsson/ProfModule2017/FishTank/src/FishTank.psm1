using module .\model.psm1
using module .\Completion.psm1
using module .\Error.psm1
using module .\PathResolution.psm1
using module .\IncludeExclude.psm1
using module .\Progress.psm1

[List[FishTank]] $fishTanks = [List[FishTank]]::new(50)

function Get-FishTankModel {
    [CmdletBinding()]
    [OutputType([FishTankModel])]
    param()
    [FishTankModel]::GetAll()
}

function Import-FishTank {
    [CmdletBinding(DefaultParameterSetName = 'Path')]
    [OutputType([FishTank])]
    param(
        # Specifies a path to one or more locations. Wildcards are permitted.
        [Parameter(Mandatory, Position = 0, ParameterSetName = "Path", ValueFromPipeline, ValueFromPipelineByPropertyName, HelpMessage = "Path to one or more locations.")]
        [ValidateNotNullOrEmpty()]
        [SupportsWildcards()]
        [string[]] $Path,

        # Specifies a path to one or more locations. Unlike the Path parameter, the value of the LiteralPath parameter is
        # used exactly as it is typed. No characters are interpreted as wildcards. If the path includes escape characters,
        # enclose it in single quotation marks. Single quotation marks tell Windows PowerShell not to interpret any
        # characters as escape sequences.
        [Parameter(Mandatory, Position = 0, ParameterSetName = "LiteralPath", ValueFromPipelineByPropertyName, HelpMessage = "Literal path to one or more locations.")]
        [Alias("PSPath")]
        [ValidateNotNullOrEmpty()]
        [string[]] $LiteralPath,

        [SupportsWildcards()]
        [string[]] $Include,

        [SupportsWildcards()]
        [string[]] $Exclude
    )

    begin {
        $wildCardFilter = [IncludeExcludeFilter]::new($Include, $Exclude)
    }

    process {
        $pathResults = $null
        if ($psCmdlet.ParameterSetName -eq 'Path') {
            $pathResults = [PathResolution]::ResolvePaths($Path, $psCmdlet.SessionState.Path)
        }
        else {
            $pathResults = [PathResolution]::ResolveLiteralPaths($LiteralPath, $psCmdlet.SessionState.Path)
        }

        foreach ($pathRes in $pathResults) {
            if ($pathRes.IsError()) {
                $pscmdlet.WriteError($pathRes.GetError())
                continue
            }
            $aPath = $pathRes.GetPath()
            if ($wildCardFilter.ShouldOutput($aPath)) {
                # Process each path
                if ([IO.Path]::GetExtension($aPath) -ne '.ftk') {
                    $psCmdlet.WriteError([Error]::UnsupportedFileFormat($aPath))
                }
                else {
                    (Get-Content -LiteralPath $aPath | ConvertFrom-Json) | ForEach-Object {
                        $model = [FishTankModel] $_.Model

                        $ft = [FishTank]::new($_.Id, $model, $_.Location)
                        $fish = [Fish[]]$_.fish
                        $ft.Fish.AddRange($fish)
                        $script:fishTanks.Add($ft)
                        $ft
                    }
                }
            }
        }
    }
}

function Export-FishTank {
    [CmdletBinding(SupportsShouldProcess, DefaultParameterSetName = "Path")]
    param(
        # Specifies a path to one or more locations. Wildcards are permitted.
        [Parameter(Mandatory, Position = 0, ParameterSetName = "Path", HelpMessage = "Path to one or more locations.")]
        [ValidateNotNullOrEmpty()]
        [SupportsWildcards()]
        [string] $Path,

        # Specifies a path to one or more locations. Unlike the Path parameter, the value of the LiteralPath parameter is
        # used exactly as it is typed. No characters are interpreted as wildcards. If the path includes escape characters,
        # enclose it in single quotation marks. Single quotation marks tell Windows PowerShell not to interpret any
        # characters as escape sequences.
        [Parameter(Mandatory, Position = 0, ParameterSetName = "LiteralPath", HelpMessage = "Literal path to one or more locations.")]
        [Alias("PSPath")]
        [ValidateNotNullOrEmpty()]
        [string] $LiteralPath,
        [Parameter(Mandatory, ValueFromPipeline)]
        [FishTank[]] $FishTank,
        [switch]$Force,
        [switch] $NoClobber
    )
    begin {
        $tanks = [List[FishTank]]::new()
    }
    process {
        $tanks.AddRange($FishTank)
    }
    end {
        $pathResult = $null

        if ($psCmdlet.ParameterSetName -eq 'Path') {
            $pathResult = [PathResolution]::ResolveUniquePath($Path, $PSCmdlet.SessionState.Path)
        }
        else {
            $pathResult = [PathResolution]::ResolveLiteralPath($LiteralPath, $PSCmdlet.SessionState.Path)
        }
        if ($pathResult.IsError() -and $pathResult.GetError().CategoryInfo.Category -eq [ErrorCategory]::ObjectNotFound) {
            $pathResult = [PathResolution]::ResolveNonExistingPath($Path, $PSCmdlet.SessionState.Path)
        }

        if ($PSCmdlet.ShouldProcess("Export-FishTank", $pathResult)) {
            if ($pathResult.IsError()) {
                $PSCmdlet.WriteError($pathResult.GetError())
            }
            else {
                $p = $pathResult.GetPath()
                if ($NoClobber -and (Test-Path $p)) {
                    throw [PathResolution]::CreatePathAlreadyExistsError($p)
                }
                $dir = [IO.Path]::GetDirectoryName($p)
                if (![IO.Directory]::Exists($dir)) {
                    mkdir $dir | Out-Null
                }
                $tanks | ConvertTo-Json -Depth 5 -Compress | Set-Content -LiteralPath $p -Force:$force
            }
        }
    }
}

function Add-FishTank {
    [OutputType([FishTank])]
    param(
        [Parameter(Mandatory)]
        [ArgumentCompleter([FishTankCompleter])]
        [string] $ModelName,
        [Parameter(Mandatory)]
        [string] $Location,
        [Parameter(ValueFromPipeline)]
        [Fish[]] $Fish
    )
    $id = 0
    foreach ($tank in $script:fishTanks) {
        if ($tank.id -gt $id) {
            $id = $tank.Id
        }
    }
    $tankModel = [FishTankModel]::GetAll().Where{$_.Modelname -eq $ModelName}
    if (-not $tankModel) {
        throw [Error]::CannotFindFishTankModel($ModelName)
    }
    $id++
    $tank = [FishTank]::new($id, $tankModel[0], $Location)
    $script:fishTanks.Add($tank)
    $tank
}

function Remove-FishTank {
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'High')]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'Id')]
        [ArgumentCompleter([FishTankCompleter])]
        [int[]] $Id,
        [Parameter(ParameterSetName = 'All', Mandatory)]
        [switch] $All,
        [switch] $Force)
    process {
        if ($PSCmdlet.ParameterSetName -eq 'All') {
            if ($Force -or $PSCmdlet.ShouldProcess("All", "Remove-FishTank")) {
                $script:fishTanks.Clear()
            }
            return
        }
        foreach ($tankId in $id) {
            $found = $false
            for ($i = 0; $i -lt $script:fishTanks.Count; $i++) {
                $tank = $script:fishTanks[$i]
                if ($tank.Id -eq $tankId) {
                    if ($Force -or $PSCmdlet.ShouldProcess("$($tank.Model), $($tank.Location)", "Remove-FishTank")) {
                        $script:fishTanks.RemoveAt($i)
                    }
                    $found = $true
                    break
                }
            }
            if (-not $found) {
                $pscmdlet.WriteError([Error]::CannotFindFishTankId($tankId))
            }
        }
    }
}

function Clear-FishTank {
    [CmdletBinding(DefaultParameterSetName = "fishtank")]
    [Alias('clft')]
    param(
        [Parameter(Mandatory, ParameterSetName = 'Id', Position = 0)]
        [ArgumentCompleter([FishTankCompleter])]
        [int[]] $Id,

        [Parameter(ValueFromPipeline, Mandatory, ParameterSetName = "fishtank")]
        [FishTank[]] $FishTank,
        [switch] $Hurry
    )

    begin { $tanks = [List[FishTank]]::new(20) }
    process {
        if ($PSCmdlet.ParameterSetName -eq 'fishtank') {
            $tanks.AddRange($FishTank)
        }
        else {
            $tanks = Get-FishTank -Id $id
            $tanks.AddRange($tanks)
        }
    }
    end {

        $pm = [ProgressManager]::new("Clean fishtank", "Removing goo", $tanks.Count)
        $i = 0
        try {
            foreach ($ft in $tanks) {
                $PSCmdlet.WriteProgress( $pm.GetCurrentProgressRecord($i++, "Cleaning fish tank in $($ft.Location)"))
                $ft.Clean($Hurry)
            }
        }
        finally {
            $PSCmdlet.WriteProgress($pm.GetCompletedRecord())
        }
    }
}

function Get-FishTank {
    [CmdletBinding(DefaultParameterSetName = 'Default')]
    [OutputType([FishTank])]
    [Alias('gft')]
    param(
        [Parameter(ParameterSetName = 'id')]
        [ArgumentCompleter([FishTankCompleter])]
        [int[]] $Id,

        [Parameter(ParameterSetName = 'default')]
        [SupportsWildcards()]
        [string[]] $Include,

        [Parameter(ParameterSetName = 'default')]
        [SupportsWildcards()]
        [string[]] $Exclude
    )
    $filter = [IncludeExcludeFilter]::new($Include, $Exclude)
    $out = [List[FishTank]]::new()
    $isId = $Id.Length -gt 0
    foreach ($tank in $script:fishTanks) {
        if ($isId) {
            if ($tank.Id -in $Id) {
                $out.Add($tank)
            }
        }
        else {
            if ($filter.ShouldOutput($tank.Location)) {
                $out.Add($tank)
            }
        }
    }
    $pscmdlet.WriteObject($out, $true)
}
