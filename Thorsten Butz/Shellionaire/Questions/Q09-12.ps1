# Q 09/12
## Which of these code snipptest will be the slowest? 

$codeA = { $n = 6; $f = 1 ; 1..$n | % { $f *= $_ } ; $f }

$codeB = { $n = 6; $f = 1; foreach ($item in 1..$n) { $f *= $item } ; $f }

$codeC = { $n = 6; $f = 1; for ($i = 1; $i -le $n; $i++) { $f *= $i }; $f }

$codeD = { $n = 6; $f = 1;  $i = 1    
    do
    {   
       $f *= $i
       $i++    
    }
    until ($i -gt $n)
    $f
}


# VERFIFICATION
# $codeA,$codeB,$codeC,$codeD | % { Invoke-Command -ScriptBlock $_ }
# $codeA,$codeB,$codeC,$codeD | % { Measure-Command -Expression $_ | Select-Object -ExpandProperty Ticks }
