# FS-Resource-Manager, RSAT-FSRM-Mgmt 
Get-WindowsFeature -ComputerName sea-sv2 -Name fs*,rsat-fs*
Install-WindowsFeature -ComputerName sea-sv2 -Name FS-Resource-Manager,RSAT-FSRM-Mgmt  -Restart -WhatIf