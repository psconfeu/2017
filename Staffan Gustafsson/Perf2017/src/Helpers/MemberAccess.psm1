using namespace System.Reflection
using namespace System.Management.Automation
using namespace System.Management.Automation.Runspaces

enum TestMethodKind {
    CodeMethod
    ScriptMethod
    ClassMethod
    DotNet
    Function
}

function AddFourthNight {
    [OutputType([datetime])]
    param([datetime]$d)
    return $d.AddDays(14)
}

class TestObject {

    [void] AddTest([TestMethodKind] $kind, $count) {

        $d = [datetime]::now
        foreach ($i in 1..$Count) {
            switch ($kind) {
                ([TestMethodKind]::CodeMethod) { $d.AddFortnightCode()}
                ([TestMethodKind]::ClassMethod) { [TestObject]::Add($d)}
                ([TestMethodKind]::ScriptMethod) { $d.AddFortnightScript() }
                ([TestMethodKind]::Function) { AddFourthNight -d $d }
                ([TestMethodKind]::DotNet) { $d.AddDays(14) }
            }
        }
    }

    static [datetime] Add([datetime] $d) {
        return $d.AddDays(14)
    }

}

$codeMethod = [Dotnet.CodeMethods].GetMethod("AddFortnight",  ([BindingFlags]::Static -bor [BindingFlags]::Public -bor [BindingFlags]::IgnoreCase))
$sb = { return $this.AddDays(14)}
$td = [TypeData]::new([datetime])
$td.Members.Add("AddFortnightScript", [ScriptMethodData]::new("AddFortnightScript", $sb))
$td.Members.Add("AddFortnightCode",   [CodeMethodData]::new("AddFortnightCode", $codeMethod))

Update-TypeData -TypeData $td -Force

class MemberAccessResult {
    [TestMethodKind] $Kind
    [TimeSpan] $time
    [int] $Count
    [long] $TimeMs
    [long] $Ticks

    MemberAccessResult([TestMethodKind] $Kind, [TimeSpan] $time, [int] $Count) {
        $this.Kind = $Kind
        $this.Time = $time
        $this.Count = $count
        $this.TimeMs = $time.TotalMilliseconds
        $this.Ticks = $time.Ticks
    }
}

