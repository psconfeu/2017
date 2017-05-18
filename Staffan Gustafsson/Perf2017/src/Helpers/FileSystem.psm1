using namespace System.Management.Automation

enum FileAccessKind {
    ChildItemName
    ChildItem
    DotNetEnum
    FastDotNetEnum
}

class FileIterResult {
    [FileAccessKind] $Kind
    [TimeSpan] $Time
    [int] $Count
    $Items
    [double] $TimeMs
}


class FileSystemIterator {

    static [FileIterResult] Iterate([string] $Path, [FileAccessKind] $Kind) {
        $Path = (Resolve-Path $Path).ProviderPath
        $sw = [Diagnostics.Stopwatch]::StartNew()
        $r = [FileIterResult] @{
            Kind = $Kind
        }

        switch ($Kind) {
            ([FileAccessKind]::ChildItemName) {
                $r.Items = @(Get-ChildItem -Recurse -File -Name -LiteralPath $Path -force -ErrorAction:SilentlyContinue)
                break
            }
            ([FileAccessKind]::ChildItem) {
                $r.Items = @(Get-ChildItem -Recurse -File -LiteralPath $Path -force -ErrorAction:SilentlyContinue)
                break
            }
            ([FileAccessKind]::DotNetEnum) {
                $r.Items = @([DirectoryEnumerator]::GetDirectoryFiles($Path, '*.*', 'AllDirectories'))
                break
            }
            ([FileAccessKind]::FastDotNetEnum) {
                $r.Items = @([PowerCode.FastDirectoryEnumerator]::EnumerateFiles($Path, '*.*', 'AllDirectories', $true))
                break
            }
        }
        $e = $sw.Elapsed
        $r.Time = $e
        $r.TimeMs = $e.TotalMilliseconds
        if ($r.Items) {
            $r.Count = $R.Items.Count
        }
        return $r
    }
}


