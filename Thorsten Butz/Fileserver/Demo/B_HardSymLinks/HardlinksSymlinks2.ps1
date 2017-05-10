## Hardlinks/Symlinks: Part 2

$code = {
    New-Item -ItemType Directory -Path 'c:\MyPictures'
    New-SmbShare -Path 'C:\MyPictures' -Name 'MyPictures' -FullAccess:Everyone

    New-Item -ItemType Directory -Path 'C:\MyPictures\Seattle'
    New-Item -ItemType SymbolicLink -Path 'C:\MyPictures\SeattleDS' -Value 'C:\MyPictures\Seattle'
    New-Item -ItemType Junction -Path 'C:\MyPictures\SeattleDJ' -Value 'C:\MyPictures\Seattle'

    New-Item -ItemType File -Path 'C:\MyPictures\Seattle\notes.txt'
    New-Item -ItemType SymbolicLink -Path 'C:\MyPictures\Seattle\notesSL.txt'  -Value 'C:\MyPictures\Seattle\notes.txt'
    New-Item -ItemType HardLink -Path 'C:\MyPictures\Seattle\notesHL.txt'  -Value 'C:\MyPictures\Seattle\notes.txt'
}

$fileserver = 'sea-sv2' 
Invoke-Command -ComputerName $fileserver -ScriptBlock $code