function Test-Admin
{
    $currentUser = New-Object Security.Principal.WindowsPrincipal $([Security.Principal.WindowsIdentity]::GetCurrent())
    $currentUser.IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)
}


function prompt { 
    $principal = [Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()
    if($principal.IsInRole([Security.Principal.WindowsBuiltInRole]'Administrator')){$color = 'red'} else {$color = 'green'}
    write-host -f $color -no '[' 
    write-host -f white -no $Env:username
    write-host -f $color -no '] '
    "$pwd> "
} 