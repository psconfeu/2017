using module ./release/Perf
using namespace System.Collections.Generic
using namespace System.Diagnostics
using namespace PowerCode


class ListResult {
    [int] $count
    [int] $ArrayMs
    [int] $ListMs
}

function Measure-Collection {
    [CmdletBinding()]
    [OutputType([ListResult])]
    param(
        [Parameter(ValueFromPipeline, Mandatory)]
        [int[]] $count)
    begin {
        $work = [List[int]]::new(10)
    }
    process {
        $work.AddRange($count)
    }
    end {

        $pr = [Powercode.ProgressWriter]::Create($pscmdlet, "List and Array", "Adding to collection", $work.Count * 2)
        try {
            foreach ($current in $work) {
                [Stopwatch] $sw = [Stopwatch]::StartNew()
                $list = @()
                $pr.WriteNext("Adding $current items to array")
                foreach ($i in 1..$current ) {
                    $list += $i
                }
                $arrayMs = $sw.Elapsed.TotalMilliseconds

                $sw.Reset()
                $sw.Start()
                $list2 = [List[int]]::new($current)
                $pr.WriteNext("Adding $current items to list")
                foreach ($i in 1..$current ) {
                    $list2.Add($i)
                }
                $listMs = $sw.Elapsed.TotalMilliseconds
                [ListResult] @{
                    Count = $current
                    ArrayMs = $arrayMs
                    ListMs = $listms
                }
            }
        }
        finally {
            $pr.WriteCompleted()
        }
    }
}
5000, 10000, 15000, 20000, 25000  <# 30000, 50000, 60000, 70000 #> | Measure-Collection -ov res

$res | Out-Chart -Property Count, ArrayMs, ListMs -ChartType Column -Title 'Collection Addition'
