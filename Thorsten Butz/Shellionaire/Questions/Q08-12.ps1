# Q 08/12

## Which of the following Cmdlets will ignore '-whatif' ?

Stop-Service -Name Netlogon -WhatIf
New-SmbShare -Name 'Shellionaire' -Path 'c:\Shellionaire' -WhatIf
Set-ExecutionPolicy -ExecutionPolicy AllSigned -WhatIf
Set-Service -Name Netlogon -StartupType Manual -WhatIf