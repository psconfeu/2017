# Gain information about shadow storage usage
vssadmin.exe list shadowstorage

$shadowStorage = Get-CimInstance -ClassName Win32_ShadowStorage
[pscustomobject] @{
   Drive = (Get-Volume -UniqueId $shadowStorage.volume.deviceid).DriveLetter
   AllocatedSpace = [System.Math]::Round(($shadowStorage.AllocatedSpace / 1GB),2)
   MaxSpace = [System.Math]::Round(($shadowStorage.MaxSpace / 1GB),2)
   UsedSpace = [System.Math]::Round(($shadowStorage.UsedSpace / 1GB),2)
}
 
# Get information volume shadow copies
vssadmin.exe list shadows
$shadowcopies = Get-CimInstance -ClassName Win32_ShadowCopy

foreach ($shadowcopy in $shadowcopies) {
    $Drive = (Get-Volume -UniqueId $shadowcopy.volumename -ErrorAction SilentlyContinue).DriveLetter 
    if ($Drive) { $drive += ':' }
    [pscustomobject] @{
        Drive = $Drive
        ClientAccessible = $shadowcopy.ClientAccessible
        'InstallDate' = $shadowcopy.InstallDate
        DeviceObject = $shadowcopy.DeviceObject    
    }
}

# Create shadow copies
# Only Windows SERVER, not available in Client SKU
# vssadmin.exe create shadow /for=c:
Invoke-CimMethod -ClassName Win32_ShadowCopy -MethodName 'Create' -Arguments @{Volume='c:\';Context='ClientAccessible'}

# Delete shadow copies
vssadmin.exe delete shadows /for=c: /oldest /quiet
vssadmin.exe delete shadows /for=c: /all /quiet

# Be careful, this may corrupt your WMI repository (imho)
# ([wmiclass]'Win32_Shadowcopy').Delete()

# Try this instead:
Get-CimInstance -ClassName Win32_Shadowcopy | Remove-CimInstance

# Mount the shadow copy
# FROM CMD.exe, MIND THE TRAILING BACKSLASH!!
# mklink /d c:\MyFolder \\?\GLOBALROOT\Device\HarddiskVolumeShadowCopy3\

$shadowcopies = Get-CimInstance -ClassName Win32_ShadowCopy
$shadowcopies.count 
foreach ($shadowcopy in $shadowcopies) {
  $mountpoint = $shadowcopy.deviceobject.split('\')[-1] + '_' + ($shadowcopy.installdate | Get-Date -UFormat %d.%M.%y_%H.%mh)
  $mountpoint
  if (Test-Path $mountpoint) { "$mountpoint exists!" } else {
    Invoke-Expression "cmd /c mklink /d $mountpoint $($shadowcopy.DeviceObject)\" # MIND THE TRAILING BACKSLASH!!
  }
}
Remove-Variable -Name mountfolders
$mountfolders = Get-ChildItem -Path 'C:' -filter 'HarddiskVolumeShadowCopy*'
$mountfolders | Select-Object Mode, Name, Linktype, Attributes
# BUG: This will not work (although it should!)
# $mountfolders | Remove-Item -Force -Recurse

# Instead: try this!
$mountfolders | ForEach-Object { $_.Delete() }