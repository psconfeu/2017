## The holy grail: Create a fresh GPO from local firewall rules

# Create a CIMSESSION // avoiding double hop issues with CredSSP
Get-CimSession | Remove-CimSession
$cred = Get-Credential
$fileserver = 'sea-sv2' 
$DisplayGroup = 'Remote File Server Resource Manager Management'
$CimSession = New-CimSession -ComputerName $fileserver -credential $cred -Authentication CredSsp

# Get GPOs
(Get-GPO -All).Displayname
Get-GPO -all | Where-Object { $_.Displayname -like 'test*' } | Remove-GPO -WhatIf

# Create a new "empty" GPO
$newgpo = 'Test 1 (Import Firewall Settings)'
New-GPO -Name $newgpo 

# No rules "inside" the new GPO 
$gpoFQDN = (Get-ADDomain).DNSRoot + '\' + $newgpo    # contoso.com\Test 1 (Import Firewall Settings)
Get-NetFirewallRule -PolicyStore $gpoFQDN | Format-Table Enabled,Display*, *store* -AutoSize

# Get current firewall rules 
$groupDisplayName = 'Remote File Server Resource Manager Management'
Get-NetFirewallRule -DisplayGroup $groupDisplayName -PolicyStoreSourceType local -CimSession $CimSession | Format-Table Enabled,Display*, *store* -AutoSize

Copy-NetFirewallRule -DisplayGroup $groupDisplayName -PolicyStoreSourceType Local –NewPolicyStore $gpoFQDN  -CimSession $CimSession -WhatIf

# Check again
Get-NetFirewallRule -PolicyStore $gpoFQDN | Format-Table Enabled,Display*, *store* -AutoSize
gpmc.msc