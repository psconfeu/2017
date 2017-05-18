using module ..\release\Perf\Perf.psd1

Describe 'Performance tests' {
    It 'Measures object member access' {
        $res = Measure-MemberAccess -Count 10000
        $res.Count | Should be 5
    }

    It 'Measures object output' {
        $res = Measure-ObjectOutput -Count 10000
        $res.Count | Should be 7
    }

    It 'Creates objects' {
        $res = Measure-ObjectCreationPerformance -count 10
        $res.Count | Should be 5
        foreach ($r in $res) {
            $r -is [ObjectCreationResult] | Should Be true
        }
    }
    It 'Iterates arrays' {
        $res = Measure-Sum -Count 1000000
        $res.Count | Should be 4
        foreach ($r in $res) {
            $r -is [LoopResult] | Should Be true
            $r.Sum | Should be 500000500000
        }
    }

    It 'Iterates piped arrays' {
        $res = Measure-Sum -count 1000 -pipeline
        $res.Count | Should be 4
        foreach ($r in $res) {
            $r -is [LoopResult] | Should Be true
            $r.Sum | Should be 500500
        }
    }

    context 'Files' {
        BeforeAll {
            $null = mkdir TestDrive:\Dir1\Dir2
            $null = Set-Content TestDrive:\Dir1\a ''
            $null = Set-Content TestDrive:\Dir1\b ''
            $null = Set-Content TestDrive:\Dir1\Dir2\a ''
        }
        AfterAll {
            [GC]::Collect(2, 'Forced')
        }

        It 'Iterates .net' {
            $res = [FileSystemIterator]::Iterate("TestDrive:\", [FileAccessKind]::DotNetEnum)
            $res.Count | Should Be 3
        }

        It 'Iterates fast .net' {
            $res = [FileSystemIterator]::Iterate("TestDrive:\", [FileAccessKind]::FastDotNetEnum)
            $res.Count | Should Be 3
        }

        It 'Iterates filesystem' {
            $res = Measure-FilesystemIteration -Path TestDrive:\
            $res.Count | Should be 4
            foreach ($r in $res) {

                $r -is [FileIterResult] | Should be true
                $r.Count | Should Be 3
                $r.Time.Ticks -gt 0 | Should Be true

            }
        }
    }
}

Remove-Module Perf -Force -ErrorAction SilentlyContinue