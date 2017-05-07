<#	
.NOTES
===========================================================================
 Created with: 	SAPIEN Technologies, Inc., PowerShell Studio 2017 v5.4.136
 Created on:   	2/28/2017 13:04
 Created by:   	DevinL
 Organization: 	SAPIEN Technologies, Inc.
 Filename:     	Manage_PSScript_Block_Logging.ps1
===========================================================================
.DESCRIPTION
	A script that handles enabling/disabling the ScriptBlockLogging feature in
PowerShell 5.0+. This is a modification of the functions found here:
https://blogs.msdn.microsoft.com/powershell/2015/06/09/powershell-the-blue-team/

I made this updated version because the original functions don't take the 
property type into account. Instead of setting the property as a REG_DWORD 
(int32) it's set as a REG_SZ (String). While PowerShell still functions with 
this type, the Policy Editor within Windows sets the property as an int, so
this follows that standard.
#>

<#
.SYNOPSIS
	Enables the ScriptBlockLogging feature of PowerShell 5.0+.
	
.DESCRIPTION
	Enables the ScriptBlockLogging feature of PowerShell 5.0+ by modifying or
creating the registry key that determines whether or not it's enabled. The
key responsible is located at 
HKLM:\Software\Policies\Microsoft\Windows\PowerShell\ScriptBlockLogging and
is supposed to be of the DWORD (int32) type. If it does not exist, it will
be created. If it does exist, but is of the wrong data type, it's deleted then
added again.
	
.EXAMPLE
	PS C:\> Enable-PSScriptBlockLogging
	
.EXAMPLE
	PS C:\> Enable-PSScriptBlockLogging -Verbose

.NOTES
	To see output as the function runs, use the -Verbose parameter.
#>
function Enable-PSScriptBlockLogging {
	[CmdletBinding()]
	param ()
	$BasePath = "HKLM:\Software\Policies\Microsoft\Windows\PowerShell\ScriptBlockLogging"
	
	if (-not (Test-Path $BasePath)) {
		Write-Verbose "ScriptBlockLogging registry key doesn't exist. Creating now."
		$null = New-Item $BasePath –Force
		
		Write-Verbose "Setting registry key value to 1 of type DWORD."
		$null = New-ItemProperty $BasePath -Name EnableScriptBlockLogging -Value "1" -PropertyType DWORD
	} else {
		if ((Get-ItemProperty -Path $BasePath).EnableScriptBlockLogging.getType().Name -eq 'Int32') {
			Write-Verbose "Key exists, updating value to 1."
			Set-ItemProperty $BasePath -Name EnableScriptBlockLogging -Value "1"
		} else {
			Write-Verbose "Key exists of wrong data type, removing existing entry."
			Remove-ItemProperty $BasePath -Name EnableScriptBlockLogging
			
			Write-Verbose "Setting new registry key value to 1 of type DWORD."
			$null = New-ItemProperty $BasePath -Name EnableScriptBlockLogging -Value "1" -PropertyType DWORD
		}
	}
}

<#
.SYNOPSIS
	Disables the ScriptBlockLogging feature of PowerShell 5.0+.
	
.DESCRIPTION
	Disables the ScriptBlockLogging feature of PowerShell 5.0+ by removing the 
registry key that determines whether or not it's enabled. The key responsible is 
located at 
HKLM:\Software\Policies\Microsoft\Windows\PowerShell\ScriptBlockLogging.
	
.EXAMPLE
	PS C:\> Disable-PSScriptBlockLogging
	
.EXAMPLE
	PS C:\> Disable-PSScriptBlockLogging -Verbose

.NOTES
	To see output as the function runs, use the -Verbose parameter.
#>
function Disable-PSScriptBlockLogging {
	[CmdletBinding()]
	param ()	
	$BasePath = "HKLM:\Software\Policies\Microsoft\Windows\PowerShell\ScriptBlockLogging"
	
	if (Test-Path $BasePath) {
		Write-Verbose "Removing registry entry for ScriptBlockLogging."
		Remove-Item HKLM:\Software\Policies\Microsoft\Windows\PowerShell\ScriptBlockLogging -Force –Recurse
	} else {
		Write-Verbose "Registry entry for ScriptBlockLogging doesn't exist."
	}
}

<#
.SYNOPSIS
	Enables the ScrtipBlockInvocationLogging feature of PowerShell 5.0+.
	
.DESCRIPTION
	Enables the ScrtipBlockInvocationLogging feature of PowerShell 5.0+ by 
modifying or creating the registry key that determines whether or not it's 
enabled. The key responsible is located at 
HKLM:\Software\Policies\Microsoft\Windows\PowerShell\ScriptBlockLogging and
is supposed to be of the DWORD (int32) type. If it does not exist, it will
be created. If it does exist, but is of the wrong data type, it's deleted then
added again.
	
.EXAMPLE
	PS C:\> Enable-PSScriptBlockInvocationLogging
	
.EXAMPLE
	PS C:\> Enable-PSScriptBlockInvocationLogging -Verbose

.NOTES
	To see output as the function runs, use the -Verbose parameter.
#>
function Enable-PSScriptBlockInvocationLogging {
	[CmdletBinding()]
	param ()	
	$BasePath = "HKLM:\Software\Policies\Microsoft\Windows\PowerShell\ScriptBlockLogging"
	
	if (-not (Test-Path $BasePath)) {
		Write-Verbose "ScriptBlockLogging registry key doesn't exist. Creating now."
		$null = New-Item $BasePath –Force
		
		Write-Verbose "Setting registry key value to 1 of type DWORD."
		$null = New-ItemProperty $BasePath -Name EnableScriptBlockInvocationLogging -Value "1" -PropertyType DWORD
	} else {
		if ((Get-ItemProperty -Path $BasePath).EnableScriptBlockLogging.getType().Name -eq 'Int32') {
			Write-Verbose "Key exists, updating value to 1."
			Set-ItemProperty $BasePath -Name EnableScriptBlockInvocationLogging -Value "1"
		} else {
			Write-Verbose "Key exists of wrong data type, removing existing entry."
			Remove-ItemProperty $BasePath -Name EnableScriptBlockInvocationLogging
			
			Write-Verbose "Setting new registry key value to 1 of type DWORD."
			New-ItemProperty $BasePath -Name EnableScriptBlockInvocationLogging -Value "1" -PropertyType DWORD
		}
	}
}

<#
.SYNOPSIS
	Disables the ScriptBlockInvocationLogging feature of PowerShell 5.0+.
	
.DESCRIPTION
	Disables the ScriptBlockInvocationLogging feature of PowerShell 5.0+ by 
removing the registry key property that determines whether or not it's enabled.
The key responsible is located at 
HKLM:\Software\Policies\Microsoft\Windows\PowerShell\ScriptBlockLogging and the
ScriptBlockInvocationLogging property is what is removed.
	
.EXAMPLE
	PS C:\> Disable-PSScriptBlockInvocationLogging
	
.EXAMPLE
	PS C:\> Disable-PSScriptBlockInvocationLogging -Verbose

.NOTES
	To see output as the function runs, use the -Verbose parameter.
#>
function Disable-PSScriptBlockInvocationLogging {
	[CmdletBinding()]
	param ()	
	$BasePath = "HKLM:\Software\Policies\Microsoft\Windows\PowerShell\ScriptBlockLogging"
	
	if (Test-Path $BasePath) {
		if ($null -ne (Get-ItemProperty -Path $basePath -Name EnableScriptBlockInvocationLogging)) {
			Write-Verbose "Removing registry key property for ScriptBlockInvocationLogging."
			Remove-ItemProperty -Path $BasePath -Name EnableScriptBlockInvocationLogging
		} else {
			Write-Verbose "Registry key property for ScriptBlockInvocationLogging doesn't exist."
		}
	} else {
		Write-Verbose "Registry entry for ScriptBlockLogging doesn't exist."
	}
}
