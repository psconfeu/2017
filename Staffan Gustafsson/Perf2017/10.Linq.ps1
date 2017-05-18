using namespace System.Collections.Generic
using namespace System.Linq


class StandardDeviation{
   hidden [decimal] $Average
  
    StandardDeviation([decimal] $average){
      $this.Average = $average
    }
  
    hidden [Func[decimal,decimal]] DiffSquare()
    {
      return $this.GetType().GetMethod("DiffSquareImpl").
        CreateDelegate([Func[decimal,decimal]], $this)
    }

    hidden [decimal] DiffSquareImpl([decimal] $current){    
      return [Math]::Pow($current - $this.Average, 2)
    }

    static [tuple[decimal,decimal]] CalculateVarianceAverage([IList[decimal]] $numbers)
    {        
        $stddev = [StandardDeviation]::new([Enumerable]::Average($numbers))                
        $sumOfSqrsAvg  = ([Enumerable]::Sum($numbers, $stddev.DiffSquare())/$numbers.Count)
        return [tuple[decimal,decimal]]::new($sumOfSqrsAvg, $stddev.Average)
    }    
}

class StandardDeviationResult{    
    [decimal] $Variance    
    [decimal] $StdDev
    [decimal] $Average
    [int] $Count
    [decimal[]] $Values
}

function Get-StandardDeviation{
  <#
      .SYNOPSIS
      Calculate standard deviation of a set of numbers

      .DESCRIPTION
      For a finite set of numbers, the standard deviation is found by taking the square root 
      of the average of the squared deviations of the values from their average value

      .PARAMETER Value
      The values to create the standard deviation of. 

      .EXAMPLE
      Get-StandardDeviation -Value 2,4,4,4,5,5,7,9
      Returns a StandardDeviationResult 
        Variance : 4
        StdDev   : 2
        Average  : 5
        Count    : 8
        Values   : {2, 4, 4, 4...}

      .EXAMPLE
      2,4,4,4,5,5,7,9 | Get-StandardDeviation
      Returns a StandardDeviationResult 
        Variance : 4
        StdDev   : 2
        Average  : 5
        Count    : 8
        Values   : {2, 4, 4, 4...}
      
      .LINK
      https://en.wikipedia.org/wiki/Standard_deviation

      .INPUTS
      System.Decimal[]

      .OUTPUTS
      StandardDeviationResult
  #>


    [CmdletBinding()]  
    [Alias('stddev')]  
    [OutputType([StandardDeviationResult])]   
    param(
        [Parameter(Mandatory,HelpMessage='Values to calculate standard deviation from', ValueFromPipeline)]
        [decimal[]] $Value
    )
    begin{
        [List[decimal]] $numbers = [List[decimal]]::new(1000)
    }
    process{        
        $numbers.AddRange($Value)        
    }
    end{
        $var = [StandardDeviation]::CalculateVarianceAverage($numbers)        
        $stddev = [StandardDeviationResult] @{
            Values = [Enumerable]::ToArray($numbers)
            Variance = $var.Item1
            Average = $var.Item2
            Count = $numbers.Count
            StdDev = [Math]::Sqrt($var.Item1)
        }
        $PSCmdlet.WriteObject($stddev)
    }
}
