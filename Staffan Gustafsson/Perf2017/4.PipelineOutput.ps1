using module .\release\Perf\Perf.psd1
[CmdletBinding()]
param([int] $Count = 10000)

Measure-ObjectOutput -ov res -Count $count
$res | Sort-Object TimeMS -Descending | Out-Chart -Property Kind, Ticks -ChartType Column -ChartSettings @{LabelFormatString = 'N0'} -Title "Write to pipeline: Count = $Count"
