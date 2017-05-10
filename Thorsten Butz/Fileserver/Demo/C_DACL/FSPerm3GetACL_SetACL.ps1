#region GET/SET-ACL

    # Create a new folder
    $hrFolder = 'C:\shares\hr'
    New-Item -ItemType Directory -Path $hrFolder -Force

    # Apply DACL from an existing folder
    $dacl = Get-Acl -Path 'C:\shares\Marketing' 
    Set-Acl -Path $hrFolder -AclObject $dacl

#endregion

#region NTFSSecurity 4.2.3 (by Raimund Andree)

    Find-Module -Name NTFSSecurity | Install-Module -Force

    Import-Module NTFSSecurity
    Get-Command -Module NTFSSecurity

    Get-NTFSOwner C:\shares\hr
    Get-NTFSAccess C:\shares\hr

#endregion