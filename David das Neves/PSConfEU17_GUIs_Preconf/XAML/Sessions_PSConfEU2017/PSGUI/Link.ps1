    Write-Host -Object 'Creating Hyperlink'
    $TargetFile = "$env:SystemRoot\System32\WindowsPowerShell\v1.0\powershell.exe" 
    $ShortcutFile = "$env:UserProfile\Desktop\PSGUI-Manager.lnk"
    $WScriptShell = New-Object -ComObject WScript.Shell
    $Shortcut = $WScriptShell.CreateShortcut($ShortcutFile)
    $Shortcut.WorkingDirectory = $GUIManagerPath
    # WindowStyle 1= normal, 3= maximized, 7=minimized
    $Shortcut.WindowStyle = 7
    # Powershell window is hidden.
    #$Shortcut.Arguments=' -windowstyle hidden "' + $GUIManagerPath + 'ExecByShortcut.ps1"'
    $Shortcut.Arguments = ' -windowstyle hidden "Start-PSGUIManager"'
    $Shortcut.TargetPath = $TargetFile
    $Shortcut.IconLocation = $GUIManagerPath + '\Resources\PSGUI_Manager.ico'
    $Shortcut.Save()
    Write-Host -Object 'Hyperlink created.' -ForegroundColor Green