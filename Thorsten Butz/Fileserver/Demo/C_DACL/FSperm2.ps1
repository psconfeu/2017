## Setting file system  permission: A proposal 
## (Reset folder structure first) 

# Different departments
$departments = 'Dept A','Dept B','Dept C'

#region BASIC SETTING

    Test-Path -Path $fileshareroot

    icacls.exe $fileshareroot /inheritance:r
    icacls.exe $fileshareroot /grant "$SeattleAdmins`:(OI)(CI)F"
    icacls.exe $fileshareroot /grant 'System:(OI)(CI)F'

#endregion 

#region  Prerequisites: AD groups 

    foreach ($department in $departments) {      
        (Get-ADGroup $department).Name 
        (Get-ADGroup "$department Mgmt").Name
        #New-ADGroup -Name $department -GroupScope Global 
        #New-ADGroup -Name "$department Mgmt" -GroupScope Global     
    }

#endregion


#region Granting department specific user rights

    foreach ($department in $departments) {
   
        if (!(Test-Path -Path "$fileshareroot\$department")){ New-Item -ItemType Directory -Path "$fileshareroot\$department" -Force}
    
        icacls.exe "$fileshareroot" /grant "$department`:(RX)"                             # Read only at entry level (Marketing)
        icacls.exe "$fileshareroot\$department" /grant "$department`:(RX)"                 # Read only at the department level 
        icacls.exe "$fileshareroot\$department" /grant "$department Mgmt`:(OI)(CI)(M)"     # Managers: change/modify permissions 
        icacls.exe "$fileshareroot\$department" /grant "$department`:(OI)(CI)(IO)(RX,W)"   # Employess: Read + Write, requires "Create Owner" perm.
    
        # CreatorOwner: 2 possibilities, choose one!
        icacls.exe "$fileshareroot\$department" /grant '*S-1-3-0:(OI)(CI)F'  # Well known SID
        icacls.exe "$fileshareroot\$department" /grant '*CO:(OI)(CI)F'       # Trustee
    }

#endregion

#region Explicit deny
    $newFolder = "$fileshareroot\Dept A\Secret\2017\"
    New-Item -ItemType Directory -Path $secretFolder -Force
    Set-Content -Path "$newFolder\secret.txt" -Value 'Is this secret?' -Force
    icacls.exe "$fileshareroot\Dept A\Secret" /deny "$BarberJ`:(OI)(CI)(F)"
    icacls.exe "$fileshareroot\Dept A\Secret\2017\secret.txt" /grant "$BarberJ`:(F)"

#endregion 

#region FILE SHARE
    $authenticatedUsers = ([System.Security.Principal.SecurityIdentifier] 'S-1-5-11').Translate([System.Security.Principal.NTAccount]).Value    New-SmbShare `        -Name 'Marketing' `        -Path 'c:\shares\Marketing' `        -ChangeAccess $authenticatedUsers `        -FolderEnumerationMode AccessBased #endregion