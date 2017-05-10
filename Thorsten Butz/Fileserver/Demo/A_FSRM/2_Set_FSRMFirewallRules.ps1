## FSRM: Howto find the required rules for File Server Resource Management Remoting? 

# Enable remote connection to your fileserver
$fileserver = 'sea-sv2'
$CimSession = New-CimSession -ComputerName $fileserver 

# Check config
Get-NetFirewallRule -DisplayName '*file*' -CimSession $CimSession   | Format-Table Enabled,Display*, *store* -AutoSize

# Now you know, what you're looking for
$DisplayGroup = 'Remote File Server Resource Manager Management'

# Locally defined FW rules
Get-NetFirewallRule -DisplayGroup $DisplayGroup -CimSession $CimSession  | Format-Table Enabled,Display*, *store* -AutoSize

# All active FW rules, incl. GPO based settings
Get-NetFirewallRule -DisplayGroup $DisplayGroup -PolicyStore ActiveStore -CimSession $CimSession  | Format-Table Enabled,Display*, *store* -AutoSize

# Local machine: no FSRM firewall rules
Get-NetFirewallRule -DisplayGroup $DisplayGroup -PolicyStore ActiveStore  | Format-Table Enabled,Display*, *store* -AutoSize

# Enable
Get-NetFirewallRule -DisplayGroup $DisplayGroup -CimSession $CimSession | Set-NetFirewallRule -Enabled True
# The FSRM console should work remotely now!

# Disable
Get-NetFirewallRule -DisplayGroup $DisplayGroup -CimSession $CimSession | Set-NetFirewallRule -Enabled False 
