using module .\release\Perf
[CmdletBinding()]
param( $Count = 100000)


Measure-Sum -Count $Count -ov res
Measure-Sum -Pipeline -Count $Count -ov respipe

$result = for ($i = 0; $i -lt $res.count; $i++) {
    $p = $respipe[$i]
    [pscustomobject] @{
        Kind = $p.Kind
        PipeTime = $p.TimeMs
        ArrayTime = $res[$i].TimeMs
    }
}

$result | Out-Chart -Property Kind, PipeTime, ArrayTime -ChartType Column -ChartSettings @{LabelFormatString = 'N0'} -Title "Looping  Count=$Count"