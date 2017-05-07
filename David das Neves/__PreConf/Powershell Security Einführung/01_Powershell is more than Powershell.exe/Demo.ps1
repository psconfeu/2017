$PS=[Powershell]::Create()
$PS.AddCommand("Get-Process")
$PS.Invoke()