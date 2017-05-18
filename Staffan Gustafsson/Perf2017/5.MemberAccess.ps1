using module .\release\Perf
[CmdletBinding()]
param( $Count = 100000)

Measure-MemberAccess -count $count -ov res
$res | Sort-Object TimeMS -Descending | Out-Chart -Property Kind, TimeMs -ChartType Column -ChartSettings @{LabelFormatString = 'N0'} -Title "function calls Count = $count"