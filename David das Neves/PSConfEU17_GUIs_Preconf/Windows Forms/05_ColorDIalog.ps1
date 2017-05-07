[reflection.assembly]::loadwithpartialname("System.Drawing") | Out-Null
[reflection.assembly]::loadwithpartialname("System.Windows.Forms") | Out-Null
$colorDialog1 = New-Object System.Windows.Forms.ColorDialog
$colorDialog1.ShowDialog()
$colorDialog1.color