# Import Set-TokenPrivilege 
. .\SetTokenPrivilege.ps1

# Who am I? 
whoami.exe /priv | Select-String -Pattern 'SeBackupPrivilege'
whoami.exe /priv /fo csv | ConvertFrom-Csv | Where-Object { $_.'Privilege Name' -eq 'SeBackupPrivilege' }

# Enable backup privilege
Set-TokenPrivilege -Privilege SeBackupPrivilege

# Access any file or folder .. 
Get-ChildItem -Path 'C:\System Volume Information' 