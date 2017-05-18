using namespace System.Text

enum StringFormatKind {
    OpAdd
    FormatOperator
    ExpandString
    StringBuilder
    StringBuilderCap
}

class StringFormatResult {
    [StringFormatKind] $Kind
    [timespan] $Time
    [int] $count
    [int] $TimeMs
    [long] $Ticks
}


class StringFormatTest {
    static [void] FormatString([StringFormatKind] $kind, [int] $count) {
        $stringPart1 = 'a' * 100
        $stringPart2 = 'b' * 100
        $s = ''
        switch ($Kind) {
            ([StringFormatKind]::OpAdd) {
                foreach ($i in 1..$Count) {
                    $s += $stringPart1 + $i + $stringPart2
                }
            }
            ([StringFormatKind]::ExpandString) {
                foreach ($i in 1..$Count) {
                    $s += "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa${i}bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb"
                }
            }
            ([StringFormatKind]::FormatOperator) {
                foreach ($i in 1..$Count) {
                    $s += "{0}{1}{2}" -f $stringPart1, $i, $stringPart2
                }
            }
            ([StringFormatKind]::StringBuilder) {
                $sb = [StringBuilder]::new()
                foreach ($i in 1..$Count) {
                    $sb.AppendFormat("{0}{1}{2}", $stringPart1, $i, $stringPart2)
                }
                $s = $sb.ToString()
            }
            ([StringFormatKind]::StringBuilderCap) {
                $sb = [StringBuilder]::new(110 * $Count)
                foreach ($i in 1..$Count) {
                    $sb.AppendFormat("{0}{1}{2}", $stringPart1, $i, $stringPart2)
                }
                $s = $sb.ToString()
            }
        }
    }
}