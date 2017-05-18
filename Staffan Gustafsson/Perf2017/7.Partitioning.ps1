# fast partitioning
(1..1000).Where($null, 'First', 10) -join ','

$a, $b = (1..1000).Where($null, 'Split', 100)
($a.Count, $b.Count) -join ', '


(1..1000).Where($null, 'Last', 10) -join ','

(1..110).Where($null, 'SkipUntil', 100) -join ','

