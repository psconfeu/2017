# Scriptblock logging
"HKLM:\Software\Policies\Microsoft\Windows\PowerShell\ScriptBlockLogging" | ForEach-Object {
    if(-not (Test-Path $_)) {  
        $null = New-Item $_ -Force  
    }  
    Set-ItemProperty $_ -Name EnableScriptBlockInvocationLogging -Value 1
    Set-ItemProperty $_ -Name EnableScriptBlockLogging -Value 1
}

# Transcription logging
"HKLM:\Software\Policies\Microsoft\Windows\PowerShell\Transcription" | ForEach-Object {
    if(-not (Test-Path $_))  {  
        $null = New-Item $_ -Force  
    }
    New-Item -ItemType Directory -Path C:\Transcription

    Set-ItemProperty $_ -Name OutputDirectory -Value C:\Transcription
    Set-ItemProperty $_ -Name EnableTranscripting -Value 1
    Set-ItemProperty $_ -Name EnableInvocationHeader -Value 1  
}

# Computer Configuration\Administrative Templates\Windows Components\Windows PowerShell
gpmc.msc

# Show the size of the event logs
Write-Output Microsoft-Windows-PowerShell/Operational,
             Microsoft-Windows-PowerShell/Admin,
             'Windows PowerShell' |
ForEach-Object {
    Get-WinEvent -ListLog $_    
} | Format-Table -AutoSize -Property FileSize,RecordCount,MaximumSizeInBytes,LogMode,LogName