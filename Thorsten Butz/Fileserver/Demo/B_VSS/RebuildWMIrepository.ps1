## Rebuild WMI repository
Get-CimInstance Win32_ShadowCopy
Get-CimClass Win32_ShadowCopy

# A: Stop service, "delete" repository
Get-Service winmgmt | Stop-Service -Force
Move-Item C:\Windows\System32\wbem\Repository C:\Windows\System32\wbem\Repository.001

# B: If required: rebuild the e WMI Repository in CMD: 
# for /f %s in ('dir /b *.mof') do mofcomp %s

Get-ChildItem -Path C:\Windows\System32\wbem -Filter *.mof | ForEach-Object { mofcomp.exe $_.FullName }

# C: Verfiy
winmgmt /verifyrepository

# If the result is shown as inconsistent, try this:
winmgmt /salvagerepository

# D: Start Service
Start-Service winmgmt 