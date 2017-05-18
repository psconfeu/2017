using namespace System.Management.Automation

class IncludeExcludeFilter {
    hidden [WildcardPattern[]] $includes
    hidden [WildcardPattern[]] $excludes

    IncludeExcludeFilter([string[]] $includes, [string[]] $excludes) {
        $this.Init($includes, $excludes, [WildcardOptions]::IgnoreCase)
    }

    IncludeExcludeFilter([string[]] $includes, [string[]] $excludes, [WildcardOptions] $options) {
        $this.Init($includes, $excludes, $options)
    }

    hidden [void] Init([string[]] $includes, [string[]] $excludes, [WildcardOptions] $options) {
        if ($includes) {
            $includePatterns = [WildcardPattern[]]::new($includes.Length)
            for ($i = 0; $i -lt $includes.Length; ++$i) {
                $includePatterns[$i] = [WildcardPattern]::new($includes[$i], $options )
            }
            $this.includes = $includePatterns
        }

        if ($excludes) {
            $excludePatterns = [WildcardPattern[]]::new($excludes.Length)
            for ($i = 0; $i -lt $excludes.Length; ++$i) {
                $excludePatterns[$i] = [WildcardPattern]::new($excludes[$i], $options)
            }
            $this.excludes = $excludePatterns
        }
    }

    [bool] ShouldOutput([string] $value) {
        if ($null -ne $this.excludes) {
            foreach ($exclude in $this.excludes) {
                if ($exclude.IsMatch($value)) {
                    return $false
                }
            }
        }

        if ($null -ne $this.includes) {
            foreach ($include in $this.includes) {
                if ($include.IsMatch($value)) {
                    return $true
                }
            }
            return $false
        }

        return $true
    }
}
