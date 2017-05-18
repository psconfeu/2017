using namespace System.Management.Automation
Register-ArgumentCompleter -CommandName Select-EverythingString -ParameterName Pattern -ScriptBlock {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter)
    ("FormatString",
        "'(?<=FormatString>)([^<]+)'",
        "'(?<=FormatString>)(?(?=N\d)(?<red>[^<]+)|(?<green>[^<]+))'").Where( {
            $_.StartsWith($wordToComplete, [StringComparison]::OrdinalIgnoreCase)
        }).Foreach( {[CompletionResult]::new($_, $_, [CompletionResultType]::ParameterValue, $_)})
}

[string]$f = resolve-path ~/documents/windowspowershell
$gist = 'https://gist.githubusercontent.com/powercode/4833804efd23045387bd5d5249d76f7b/raw/b1f37315919e9d4f7dd10e7321b00ccd3b016d13/MatchInfoV5.format.ps1xml'
[System.Net.WebClient]::new().DownloadFile($gist, "$f/MatchInfoColor.format.ps1xml")
# Update-FormatData -prepend "$f/MatchInfoColor.format.ps1xml"


