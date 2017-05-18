using namespace System.Text
using namespace System.Diagnostics
using module ./release/Perf


1000, 2000, 3000, 4000 | Measure-StringFormat -ov res

$res | Group-Object Kind | ForEach-Object {
    $r = @{Kind = $_.Group[0].Kind }
    $_.Group.Foreach{
        $r["N$($_.Count)"] = $_.Ticks
    }
    [PSCustomObject] $r
} | Out-Chart -Property Kind, N1000, N2000,N3000, N4000 -Title "String Format" -ChartType Column


Measure-StringFormat -Count 20000 -kind StringBuilder, StringBuilderCap