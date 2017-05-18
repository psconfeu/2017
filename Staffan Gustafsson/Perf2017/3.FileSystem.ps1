using module .\release\Perf
[CmdletBinding()]
param()

Measure-FileSystemIteration -ov res -Path c:\windows\system32

$res | Out-Chart -Property Kind, TimeMs -ChartType Column -Title "File system enumeration: Path = $path"