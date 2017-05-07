Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
$window = New-Object System.Windows.Forms.Form
$window.Width = 1000
$window.Height = 800
 
  $Label = New-Object System.Windows.Forms.Label
  $Label.Location = New-Object System.Drawing.Size(10,10)
  $Label.Text = "Text im Fenster"
  $Label.AutoSize = $True

$window.Controls.Add($Label)
[void]$window.ShowDialog()