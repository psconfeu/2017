using namespace System.Management.Automation
using namespace System.Collections.Generic
using namespace System.Diagnostics

class PathResult {
    [object] $Result

    PathResult([string] $path) {
        $this.Result = $path
    }

    PathResult([ErrorRecord] $errorRecord) {
        $this.Result = $errorRecord
    }

    [string] GetPath() {
        $path = $this.Result -as [string]
        if ($null -eq $path) {
            throw [System.InvalidOperationException]::new("Result is not a path")
        }
        return $path
    }

    [ErrorRecord] GetError() {
        $err = $this.Result -as [ErrorRecord]
        if ($null -eq $err) {
            throw [System.InvalidOperationException]::new("Result is not an ErrorRecord")
        }
        return $err
    }

    [bool] IsError() {
        return $this.Result -is [ErrorRecord]
    }
}

class PathResolution {
    <# Error if it resolves to more than one path #>
    static [PathResult] ResolveUniquePath([string] $path, [PathIntrinsics] $pathIntrinsics) {
        if (!(Test-Path -Path $path)) {
            return [PathResolution]::CreatePathNotFoundErrorRecord($path)
        }
        else {
            $provider = $null
            $resolved = $pathIntrinsics.GetResolvedProviderPathFromPSPath($path, [ref] $provider)
            if ($resolved.Count -eq 1) {
                return $resolved[0]
            }
        }
        return [PathResolution]::CreatePathResolvesToMultipleFilesErrorRecord($path)
    }

    static [PathResult] ResolveLiteralPath([string] $path, [PathIntrinsics] $pathIntrinsics) {
        if (!(Test-Path -LiteralPath $path)) {
            return [PathResolution]::CreatePathNotFoundErrorRecord($path)
        }
        else {
            return $pathIntrinsics.GetUnresolvedProviderPathFromPSPath($path)
        }
    }

    static [PathResult[]] ResolveLiteralPaths([string[]] $paths, [PathIntrinsics] $pathIntrinsics) {
        $retVal = [PathResult[]]::new($paths.Length)
        for ($i = 0; $i -lt $retVal.Length; $i++) {
            $retVal[$i] = [PathResolution]::ResolveLiteralPath($paths[$i], $pathIntrinsics)
        }
        return $retVal
    }

    static [List[PathResult]] ResolvePaths([string[]] $paths, [PathIntrinsics] $pathIntrinsics) {
        $retVal = [List[PathResult]]::new($paths.Length)
        foreach ($aPath in $paths) {
            if (!(Test-Path -Path $aPath)) {
                $retVal.Add([PathResolution]::CreatePathNotFoundErrorRecord($aPath))
            }
            else {
                $provider = $null
                $resolved = $pathIntrinsics.GetResolvedProviderPathFromPSPath($aPath, [ref] $provider)
                foreach ($r in $resolved) {
                    $retVal.Add([PathResult]::new($r))
                }
            }
        }
        return $retVal
    }

    static [PathResult[]] ResolveNonExistingPath([string] $path, [PathIntrinsics] $pathIntrinsics) {
        return [PathResult]::new($pathIntrinsics.GetUnresolvedProviderPathFromPSPath($path))
    }

    static [ErrorRecord] CreatePathNotFoundErrorRecord([string] $path) {
        $ex = [ItemNotFoundException]::new("Cannot find path '$path' because it does not exist.")
        $category = [System.Management.Automation.ErrorCategory]::ObjectNotFound
        $errRecord = [ErrorRecord]::new($ex, 'PathNotFound', $category, $path)
        return $errRecord
    }

    static [ErrorRecord] CreatePathResolvesToMultipleFilesErrorRecord([string] $path) {
        $ex = [ArgumentException]::new("The '$path' resolves to more than one file.")
        $category = [System.Management.Automation.ErrorCategory]::InvalidArgument
        $errRecord = [ErrorRecord]::new($ex, 'PathNotUnique', $category, $path)
        return $errRecord
    }

    static [ErrorRecord] CreatePathAlreadyExistsError([string] $path) {
        $ex = [IO.IOException]::new("File '$path' already exists.")
        $category = [System.Management.Automation.ErrorCategory]::ResourceExists
        $errRecord = [ErrorRecord]::new($ex, 'NoClobber', $category, $path)
        return $errRecord
    }
}

