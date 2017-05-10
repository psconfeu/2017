## Variables 
$fileserver = 'sea-sv2'
$cimsession = New-CimSession -ComputerName $fileserver
# Authenticated Users (localized)
$authenticatedUsers = ([System.Security.Principal.SecurityIdentifier] 'S-1-5-11').Translate([System.Security.Principal.NTAccount]).Value
# $teams = 'hr','it','marketing','research','sales'
$teams = 'TeamX','TeamY','TeamZ'

<#  
    START FROM SCRATCH    
    foreach ($Team in $teams) { Get-SmbShare -Name $Team -CimSession $cimsession -ErrorAction SilentlyContinue | Remove-SmbShare -Force } 
    Remove-Item "\\$fileserver\C`$\shares" -Recurse -Force -ErrorAction SilentlyContinue 
#>

# Create shares
foreach ($Team in $teams) {
    
    New-Item -ItemType Directory -Path "\\$fileserver\C`$\shares\$Team"  -ErrorAction SilentlyContinue
        New-SmbShare `    -CimSession $cimsession `    -Name $Team `    -Path ('c:\shares\' + $Team) `    -ChangeAccess $authenticatedUsers `    -FolderEnumerationMode AccessBased -ConcurrentUserLimit 20 
}

Get-SmbShare -CimSession $cimsession | 
    Format-Table PSComputername,Name, Path, Description,FolderEnumerationMode,ConcurrentUserLimit