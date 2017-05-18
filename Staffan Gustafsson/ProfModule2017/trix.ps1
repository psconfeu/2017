
function ctor($name = 'ClassName') {
    $members = Get-Clipboard | Foreach-Object Trim | Where-Object {$_}
    $params = $members -replace '\s+', '' | Join-Item -Delimiter ", "

    $impl = $members -replace '(\[\w+\])\s+\$(\w+)', '$this.$2 = $$$2'  | Join-Item -Delimiter "`r`n        "
    $ofs = "`r`n    "
    $ctor = @"
    $name($params) {
        $impl
    }
"@
    $ctor | Set-Clipboard
    $ctor
}



class CommandParameter {
    [string] $Command
    [string] $ParameterName
    [string] $Metadata
}

function Get-ModuleParameter {
    [OutputType([CommandParameter])]
    param([string] $ModuleName)
    (Get-Command -module $ModuleName).Foreach{
        $command = $_
        $_.Parameters.Values.Where{
            $_.name -notmatch '(Error|Warning|Information|Pipeline|Out)(Action|Variable)|Debug|Verbose|OutBuffer|WhatIf|Confirm'
        }.Foreach{
            [CommandParameter] @{
                Command = $command
                ParameterName = $_.Name
                MetaData = $_
            }
        }

    }
}

Register-ArgumentCompleter -CommandName Get-ModuleParameter -ParameterName ModuleName -ScriptBlock {
    param($command, $parameter, $wordToComplete, $ast, $fake)
    (Get-Module).Where{$_.Name.StartsWith($wordToComplete, [System.StringComparison]::OrdinalIgnoreCase)}
}

Register-ArgumentCompleter -CommandName Import-Fishtank -ParameterName Path -ScriptBlock {
    param($command, $parameter, $wordtocomplete, $ast, $fake)
    $separams = @{
        Extension = 'ftk'
        Global = $true
    }
    if ($wordtocomplete) {$separams.PathInclude = $wordToComplete}

    Search-Everything @separams
}

