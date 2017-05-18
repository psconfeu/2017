using module .\release\Perf
[CmdletBinding()]
param($Count = 100000)

Measure-ObjectCreationPerformance -ov res -Count $Count

$chartParam = @{
    Property ='type','mem','ticks'
    ChartType = 'column'
    ChartSettings = @{LabelFormatString = 'N0'}
    Title = "Object Creation Count=$count"
}
$res | Out-Chart @chartParam