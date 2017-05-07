#Loading Assemblies
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

#Adding Form
$window = New-Object System.Windows.Forms.Form
$window.Width = 1000
$window.Height = 800

#Creating and Adding Objects
$Label = New-Object System.Windows.Forms.Label
$Label.Location = New-Object System.Drawing.Size(10,10)
$Label.Text = "Text im Fenster"
$Label.AutoSize = $True
$window.Controls.Add($Label)

$windowTextBox = New-Object System.Windows.Forms.TextBox
$windowTextBox.Location = New-Object System.Drawing.Size(50,50)
$windowTextBox.Size = New-Object System.Drawing.Size(500,500)
$window.Controls.Add($windowTextBox)
 
$windowButton = New-Object System.Windows.Forms.Button
$windowButton.Location = New-Object System.Drawing.Size(10,60)
$windowButton.Size = New-Object System.Drawing.Size(50,50)
$windowButton.Text = "OK"

#Adding Events/Eventhandlers
$windowButton.Add_Click({
    write-host $windowTextBox.Text
    $window.Dispose()
})
 
$window.Controls.Add($windowButton)

$window.ShowDialog()