using namespace System.Collections
using namespace System.Collections.Generic
using namespace System.Management.Automation
using namespace System.Management.Automation.Language
using module .\Model.psm1

class FishTankCompleter : IArgumentCompleter {
    [IEnumerable[CompletionResult]] CompleteArgument(
        [string] $command,
        [string] $parameter,
        [string] $wordToComplete,
        [CommandAst] $ast,
        [IDictionary] $fakeBoundParameter
    ) {
        $result = [List[CompletionResult]]::new(10)
        switch ($parameter) {
            'ModelName' { $this.CompleteModel($result, $wordToComplete) }
            'Id' { $this.CompleteId($result, $wordToComplete) }
        }
        return $result
    }

    [void] CompleteModel([List[CompletionResult]] $result, [string] $wordToComplete) {
        foreach ($ftm in [FishTankModel]::GetAll()) {
            if ($ftm.ModelName.StartsWith($wordToComplete, [StringComparison]::OrdinalIgnoreCase)) {
                [FishTankCompleter]::AddCompletionValue($result, $ftm.ModelName)
            }
        }
    }

    [void] CompleteId([List[CompletionResult]] $result, [string] $wordToComplete) {
        (Get-FishTank).Foreach{
            $id = $_.Id
            $location = $_.Location
            $s = "$id - $location"
            if ($s.StartsWith($wordToComplete, [System.StringComparison]::OrdinalIgnoreCase)) {
                [FishTankCompleter]::AddCompletionValue($result, $id, $s, $_.Model.ToString())
            }
        }
    }

    static [void] AddCompletionValue([List[CompletionResult]] $result, [string] $name) {
        [FishTankCompleter]::AddCompletionValue($result, $name, $name, $name)
    }

    static [void] AddCompletionValue([List[CompletionResult]] $result, [string] $name, [string]$tooltip) {
        [FishTankCompleter]::AddCompletionValue($result, $name, $name, $tooltip)
    }

    static [void] AddCompletionValue([List[CompletionResult]] $result, [string] $name, [string] $listItem, [string] $tooltip) {
        $text = $name
        if ($name.Contains(' ')) {
            $text = "'$name'"
        }
        $result.Add([CompletionResult]::new($text, $listItem, [CompletionResultType]::ParameterValue, $tooltip))
    }
}

