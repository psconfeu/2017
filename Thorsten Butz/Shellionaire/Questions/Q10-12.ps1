# Q 10/12

## Which of the following cmdlets provide the highest amount of "ParameterSets"?
Enter-PSSession
Invoke-Command
Measure-Object
Where-Object

#region verification
    Get-Command | 
      Where-Object { $_.ParameterSets.Count -gt 1 } | 
        Select-Object Name, @{ l='Count'; e={$_.ParameterSets.Count}} | 
          Sort-Object Count -Descending
#endregion