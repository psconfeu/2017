[void] [System.Reflection.Assembly]::LoadWithPartialName('System.Windows.Forms')
[void] [System.Reflection.Assembly]::LoadWithPartialName('System.Drawing') 
$objForm = New-Object -TypeName System.Windows.Forms.Form 
$objForm.Text = 'Data Entry Form'
$objForm.Size = New-Object -TypeName System.Drawing.Size -ArgumentList (300, 200) 
$objForm.StartPosition = 'CenterScreen'
$objForm.KeyPreview = $True 

$objForm.Add_KeyDown({
    if ($_.KeyCode -eq 'Enter') 
    {
      foreach ($objItem in $objListbox.SelectedItems)
      {
        $x += $objItem
      }
      Write-Host $x
      $objForm.Close()
    }
})
$objForm.Add_KeyDown({
    if ($_.KeyCode -eq 'Escape') 
    {
      $objForm.Close()
    }
})
$OKButton = New-Object -TypeName System.Windows.Forms.Button
$OKButton.Location = New-Object -TypeName System.Drawing.Size -ArgumentList (75, 120)
$OKButton.Size = New-Object -TypeName System.Drawing.Size -ArgumentList (75, 23)
$OKButton.Text = 'OK'
$OKButton.Add_Click(
  {
    foreach ($objItem in $objListbox.SelectedItems)
    {
      $x += $objItem
    }
    $objForm.Close()
})
$objForm.Controls.Add($OKButton)
$CancelButton = New-Object -TypeName System.Windows.Forms.Button
$CancelButton.Location = New-Object -TypeName System.Drawing.Size -ArgumentList (150, 120)
$CancelButton.Size = New-Object -TypeName System.Drawing.Size -ArgumentList (75, 23)
$CancelButton.Text = 'Cancel'
$CancelButton.Add_Click({
    $objForm.Close()
})
$objForm.Controls.Add($CancelButton)
$objLabel = New-Object -TypeName System.Windows.Forms.Label
$objLabel.Location = New-Object -TypeName System.Drawing.Size -ArgumentList (10, 20) 
$objLabel.Size = New-Object -TypeName System.Drawing.Size -ArgumentList (280, 20) 
$objLabel.Text = 'Suchen Sie sich etwas aus:'
$objForm.Controls.Add($objLabel) 
$objListbox = New-Object -TypeName System.Windows.Forms.Listbox 
$objListbox.Location = New-Object -TypeName System.Drawing.Size -ArgumentList (10, 40) 
$objListbox.Size = New-Object -TypeName System.Drawing.Size -ArgumentList (260, 20) 
$objListbox.SelectionMode = 'MultiExtended'
[void] $objListbox.Items.Add('1. Element')
[void] $objListbox.Items.Add('2. Element')
[void] $objListbox.Items.Add('3. Element')
[void] $objListbox.Items.Add('4. Element')
[void] $objListbox.Items.Add('5. Element')
$objListbox.Height = 70
$objForm.Controls.Add($objListbox) 
[void] $objForm.ShowDialog()
