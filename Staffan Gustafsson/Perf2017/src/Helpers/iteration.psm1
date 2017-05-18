
enum LoopKind {  ForeachObject; ForeachLang ; MagicForeach; For }

class LoopResult {
    [LoopKind] $Kind
    [long] $Sum
    [int] $Count
    [TimeSpan] $Time
    [double] $TimeMs
    [long] $Ticks
}

function Get-Sum {
    [OutputType([long])]
    param(
        [Parameter(ValueFromPipelineByPropertyName, ValueFromPipeline)]
        [int[]] $Number
        ,
        [LoopKind] $Kind
    )
    begin {
        [long]$sum = 0
    }
    process {
        switch ($Kind) {
            ([LoopKind]::ForeachObject) {
                <# test #> $Number | ForEach-Object { $sum += $_ }
                break
            }
            ([LoopKind]::ForeachLang) {
                <# test #> foreach ($n in $Number) { $sum += $n }
                break
            }
            ([LoopKind]::MagicForeach) {
                <# test #> $Number.Foreach{$sum += $_ }
                break
            }
            ([LoopKind]::For) {
                <# test #>
                for ($i = 0; $i -lt $Number.Length; $i++) {
                    $sum += $Number[$i]
                }
                break
            }
        }
    }
    end {
        $sum
    }
}
