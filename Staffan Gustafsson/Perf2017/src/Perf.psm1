using module .\Helpers\ObjectAllocation.psm1
using module .\Helpers\Iteration.psm1
using module .\Helpers\Filesystem.psm1
using module .\Helpers\PipelineOutput.psm1
using module .\Helpers\MemberAccess.psm1
using module .\Helpers\Progress.psm1
using module .\Helpers\StringFormat.psm1
using module .\Helpers\WebDownload.psm1

Set-StrictMode -Version latest

function Measure-ObjectCreationPerformance {
    [CmdletBinding()]
    param(
        $Count = 1000000
    )
    [GC]::Collect(2)

    $perfCounter = [MemoryPerfCounters]::new()
    $tester = [Tester]::new($count, $perfCounter)
    [GC]::Collect(2, 'Forced')
    [GC]::WaitForPendingFinalizers()

    $i = 0
    $kinds = [Enum]::GetValues([ObjType])
    $pr = [Powercode.ProgressWriter]::Create($pscmdlet, "ObjectCreation", "Creating objects", $kinds.Count)
    try {
        $kinds | ForEach-Object {
            $pr.WriteNext($_)
            $tester.TestCreation($_)
        }
    }
    finally {
        $pr.WriteCompleted()
    }
}

function Measure-Sum {
    [CmdletBinding()]
    [OutputType([LoopResult])]
    param(
        [int] $Count = 1000000,
        [switch] $Chart,
        [switch] $Pipeline
    )
    $kinds = [Enum]::GetValues([LoopKind])
    $pr = [Powercode.ProgressWriter]::Create($pscmdlet, "Iterations", "looping over collection of integers", $kinds.Count)
    try {
        $kinds | ForEach-Object {
            $pr.WriteNext($_)
            $sw = [Diagnostics.Stopwatch]::StartNew()
            if ($Pipeline) {
                $sum = (1..$Count) | Get-Sum -Kind $_
            }
            else {
                $sum = Get-Sum -Number (1..$Count) -Kind $_
            }
            $e = $sw.Elapsed
            [LoopResult] @{  Kind = $_ ; Sum = $sum; Count = $count; Time = $e; TimeMs = $e.TotalMilliseconds; Ticks = $e.Ticks}
        }
    }
    finally {$pr.WriteCompleted()}
}

function Measure-FileSystemIteration {
    [CmdletBinding()]
    param(
        [string] $Path = "$env:SystemRoot\System32"
    )
    $kinds = [Enum]::GetValues([LoopKind])
    $pr = [Powercode.ProgressWriter]::Create($pscmdlet, "FileSystem enum", "traversing", $kinds.Count)
    try {
        $kinds | ForEach-Object {
            $res = [FileSystemIterator]::Iterate($Path, $_)
            $res
        }
    }
    finally {$pr.WriteCompleted()}

}

function Measure-ObjectOutput {
    [CmdletBinding()]
    [OutputType([ObjectOutputResult])]
    param(
        [Parameter(Mandatory)]
        [int]$Count)

    $kinds = [Enum]::GetValues([ObjectOutputKind])
    $pr = [Powercode.ProgressWriter]::Create($pscmdlet, "Pipeline output", "measuring", $kinds.Count)
    try {
        $kinds | ForEach-Object {
            $pr.WriteNext($_)
            $sw = [System.Diagnostics.Stopwatch]::StartNew()
            Write-ObjectOutput -Kind $_ -Count $Count | out-null
            $e = $sw.Elapsed
            return [ObjectOutputResult] @{
                Kind = $_
                Count = $count
                Time = $e
                TimeMs = $e.TotalMilliseconds
                Ticks = $e.Ticks
            }
        }
    }
    finally {
        $pr.WriteCompleted()
    }
}

function Measure-MemberAccess {
    [CmdletBinding()]
    [OutputType([MemberAccessResult])]
    param([int] $Count)
    $kinds = [Enum]::GetValues([TestMethodKind])
    $pr = [Powercode.ProgressWriter]::Create($pscmdlet, "Member Access", "Calling Members", $kinds.Count)
    try {
        $kinds | ForEach-Object {
            $pr.WriteNext($_)
            $sw = [System.Diagnostics.Stopwatch]::StartNew()
            $to = [TestObject]::new()
            $to.AddTest($_, $Count)
            $e = $sw.Elapsed
            return [MemberAccessResult]::new($_, $e, $count)
        }
    }
    finally {
        $pr.WriteCompleted()
    }
}



function Measure-StringFormat {
    [CmdletBinding()]
    [OutputType([StringFormatResult])]
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [int]$Count,
        [StringFormatKind[]] $Kind = [Enum]::GetValues([StringFormatKind]))

    process {

        $pr = [Powercode.ProgressWriter]::Create($pscmdlet, "String format", "measuring", $kind.Count)
        try {
            $kind | ForEach-Object {
                $pr.WriteNext($_)
                $sw = [Stopwatch]::StartNew()
                [StringFormatTest]::FormatString($_, $Count)
                $e = $sw.Elapsed
                return [StringFormatResult] @{
                    Kind = $_
                    Count = $count
                    Time = $e
                    TimeMs = $e.TotalMilliseconds
                    Ticks = $e.Ticks
                }
            }
        }
        finally {
            $pr.WriteCompleted()
        }
    }
}


function Measure-WebDownload {
    [CmdletBinding()]
    [OutputType([MemberAccessResult])]
    param([uri] $Uri)

    $kinds = [Enum]::GetValues([Downloadkind])
    $pr = [Powercode.ProgressWriter]::Create($pscmdlet, "Web Download", "filling the pipes", $kinds.Count)
    $tmpFile = "$env:temp\webdownload.zip"
    try {
        $kinds | ForEach-Object {
            $pr.WriteNext($_)
            $sw = [System.Diagnostics.Stopwatch]::StartNew()
            switch ($_) {
                ([Downloadkind]::IWRProgress) {
                    $ProgressPreference = 'SilentlyContinue'
                    Invoke-WebRequest -Uri $Uri -OutFile $tmpFile
                }
                ([Downloadkind]::IWR) {Invoke-WebRequest -Uri $Uri -OutFile $tmpFile }
                ([Downloadkind]::WebClient) {[System.Net.WebClient]::new().DownloadFile($uri, $tmpFile)}
            }
            $e = $sw.Elapsed
            return [WebDownloadResult]::new($_, $e)
        }
    }
    finally {
        Remove-Item $tmpFile
        $pr.WriteCompleted()
    }
}