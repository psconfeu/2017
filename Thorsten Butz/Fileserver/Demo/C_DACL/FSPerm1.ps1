## File system permissions (Part 1)
#region Setup

    # Variables
    $currentuser = 'contoso\butzadmin'
    $BarberJ = 'contoso\BarberJ'
    $MossM = 'contoso\MossM'
    $SeattleAdmins = 'contoso\Seattle Domain Admins'
    $LondonAdmins = 'contoso\London Domain Admins'
    $VancouerAdmins = 'contoso\Vancouver Domain Admins'
    $fileshareroot = 'c:\shares\Marketing'

    # Start from scratch
    Remove-Item -Path $fileshareroot -Recurse -Force
    New-Item -ItemType Directory -Path ($fileshareroot + '\Dept A\Team A1') -Force

#endregion 

#region BASICS
    # First stop: removing all (inherited) permissions 
    icacls.exe $fileshareroot /inheritance:r

    # List current permissions (there should not be a lot ..)
    icacls.exe $fileshareroot 

    # Take care of the ownership
    Get-Acl $fileshareroot

    icacls.exe $fileshareroot /grant "$SeattleAdmins`:(OI)(CI)(F)"
    icacls.exe $fileshareroot /grant "$LondonAdmins`:(CI)(F)"
    icacls.exe $fileshareroot /grant "$VancouerAdmins`:(F)"

    icacls.exe $fileshareroot /grant "$currentuser`:(RX)"
    icacls.exe $fileshareroot /grant "$currentuser`:(F)" # Full Control, this folder only
    icacls.exe $fileshareroot /remove "$currentuser`:(F)" # Full Control, this folder only

    # Avoid the "t" flag
    icacls.exe $fileshareroot /grant "$MossM`:(OI)(CI)(F)" /t



#endregion 



#region RESEARCH

    icacls.exe $fileshareroot /inheritance:r

    # We know, that would work:
    # icacls.exe $fileshareroot /grant "$currentuser`:(OI)(CI)(F)"

    # Lets try to become the owner
    icacls.exe $fileshareroot /setowner $currentuser /t 

    # TAKEOWN.EXE: May the force be with you!
    #  /r: recursive /d Y: YES to everything when prompted
    takeown.exe /f $fileshareroot /r /d Y   

    # Takeown
    # /a: Administrators group  
    takeown.exe /f $fileshareroot /a /r /d Y    

    # The magical "reset" switch
    icacls.exe "$fileshareroot\Dept A" /grant "$MossM`:(OI)(CI)(F)" /t
    icacls.exe "$fileshareroot\Dept A" /grant "$BarberJ`:(OI)(CI)(F)"

    icacls.exe "$fileshareroot\Dept A" /reset
    icacls.exe $fileshareroot /reset /t 


#endregion