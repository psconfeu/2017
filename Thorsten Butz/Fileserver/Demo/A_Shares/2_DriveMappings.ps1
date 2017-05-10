# Reset mappings
net.exe use * /del /y

# A: Persistent Mappings
net.exe use x: \\sea-sv2\TeamX /persistent:yes
New-SmbMapping -LocalPath 'y:' -RemotePath '\\sea-sv2\TeamY' -Persistent $true
New-PSDrive -Name 'z' -PSProvider FileSystem -Root '\\sea-sv2\TeamZ' -Persist

# B: Non-Persistent Mappings
net.exe use x: \\sea-sv2\TeamX 
New-SmbMapping -LocalPath 'y:' -RemotePath '\\sea-sv2\TeamY'
New-PSDrive -Name 'z' -PSProvider FileSystem -Root '\\sea-sv2\TeamZ' 

Test-Path 'x:','y:','z:'
Get-Process -Name explorer | Stop-Process

# TRY LOGON/LOGOFF 