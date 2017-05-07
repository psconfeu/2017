Add-Type -AssemblyName System.Windows.Forms
$Form = New-Object system.Windows.Forms.Form
$Form.Text = "Sample Form"
$Font = New-Object System.Drawing.Font("Times New Roman",18,[System.Drawing.FontStyle]::Italic)
# Font styles are: Regular, Bold, Italic, Underline, Strikeout
$Form.Font = $Font
$Label = New-Object System.Windows.Forms.Label
$Label.Text = "This form is very simple."
$Label.AutoSize = $True
$Form.Controls.Add($Label)
$Form.ShowDialog()