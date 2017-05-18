
$count = 100000
$value = 1 .. $Count

enum ObjectOutputKind{
    WriteObjectMethod
    WriteObjectMethodNoEnum
    WriteObjectMethodForeach
    NonCaptured
    NonCapturedForeach
    WriteOutputCmdletForeach
    WriteOutputCmdletPipe
    WriteOutputCmdletNoEnum
}

class ObjectOutputResult {
    [ObjectOutputKind] $Kind
    [timespan] $Time
    [int] $count
    [int] $TimeMs
    [long] $Ticks
}

function Write-ObjectOutput {
    [CmdletBinding()]
    [OutputType([ObjectOutputResult])]
    param([ObjectOutputKind] $kind, [int] $count)

    [int[]] $i = 1..$Count

    $res = switch ($kind) {
        ([ObjectOutputKind]::WriteOutputCmdletForeach) { foreach ($v in $i) { Write-Output $v } }
        ([ObjectOutputKind]::WriteOutputCmdletPipe) { $i | Write-Output }
        ([ObjectOutputKind]::WriteOutputCmdletNoEnum) { Write-Output $i -NoEnumerate }
        ([ObjectOutputKind]::WriteObjectMethodForeach) { foreach ($v in $i) { $pscmdlet.WriteObject($v) }}
        ([ObjectOutputKind]::WriteObjectMethod) { $pscmdlet.WriteObject($i, $true) }
        ([ObjectOutputKind]::WriteObjectMethodNoEnum) {$pscmdlet.WriteObject($i, $false)}
        ([ObjectOutputKind]::NonCapturedForeach) { foreach($ii in $i){$ii} }
        ([ObjectOutputKind]::NonCaptured) { $i }

    }
}

