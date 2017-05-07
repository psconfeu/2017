$remember=[System.Windows.Forms.MessageBox]::Show("$($selection.Application) Frage mit ja oder nein" , "Fenstertitel" , 4)
if ($remember -eq "Yes") {write-host "Yes"}else {write-host "Nein"}
