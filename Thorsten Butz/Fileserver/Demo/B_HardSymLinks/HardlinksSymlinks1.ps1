## Hardlinks/Symlinks: Part 1

Get-Item -Path 'C:\Documents and Settings' -Force | fl *
Get-ChildItem -Path 'C:' -Filter Do* -Force  | fl *

New-Item -ItemType Directory -Path c:\MyMusic
New-Item -ItemType File -Path c:\MyMusic\catalogue.txt 
New-Item -ItemType SymbolicLink -Path C:\MyMusicDS -Value C:\MyMusic
New-Item -ItemType Junction -Path C:\MyMusicDJ -Value C:\MyMusic
 
Remove-Item -Path C:\MyMusicDS -Force  -Recurse # Error
Remove-Item -Path C:\MyMusicDJ -Force -Recurse

(Get-Item -Path C:\MyMusicDS).Delete()

# Old style: Directories // take care => reversed compared to "ln" on Unix
cmd /c mklink C:\MyMusicDS C:\MyMusic /D 
cmd /c mklink C:\MyMusicDJ C:\MyMusic /J

# Files
New-Item -ItemType SymbolicLink -Path C:\MyMusic\catalogueSL.txt -Value C:\MyMusic\catalogue.txt
New-Item -ItemType HardLink -Path C:\MyMusic\catalogueHL.txt -Value C:\MyMusic\catalogue.txt

Remove-Item -Path C:\MyMusic\catalogueSL.txt 
Remove-Item -Path C:\MyMusic\catalogueHL.txt

# Old style: Files
cmd /c mklink C:\MyMusic\catalogueSL.txt C:\MyMusic\catalogue.txt
cmd /c mklink C:\MyMusic\catalogueHL.txt C:\MyMusic\catalogue.txt /h
$items = @()
$items = Get-ChildItem -Path '.' -Filter 'MyMusic*' -Force 
$items += Get-ChildItem -Path C:\MyMusic  
$items | Select-Object Attributes,Name, Linktype, Mode

# Super old style: Files only
fsutil hardlink list C:\MyMusic\catalogue.txt
fsutil hardlink create C:\MyMusic\catalogueHL2.txt C:\MyMusic\catalogue.txt

fsutil reparsepoint query C:\MyMusicDS
fsutil reparsepoint query C:\MyMusicDJ

# Different volume
New-Item -ItemType SymbolicLink -Path e:\MyMusicDS -Value C:\MyMusic\                    # YES
New-Item -ItemType Junction -Path e:\MyMusicDJ -Value C:\MyMusic\                        # YES
New-Item -ItemType SymbolicLink -Path e:\catalogueSL.txt -Value C:\MyMusic\catalogue.txt # YES
New-Item -ItemType HardLink -Path e:\catalogueHL.txt -Value C:\MyMusic\catalogue.txt     # NO