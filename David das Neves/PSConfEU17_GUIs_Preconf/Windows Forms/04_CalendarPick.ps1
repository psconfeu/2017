[void] [System.Reflection.Assembly]::LoadWithPartialName('System.Windows.Forms')
[void] [System.Reflection.Assembly]::LoadWithPartialName('System.Drawing') 
$objForm = New-Object -TypeName Windows.Forms.Form
$objForm.Text = 'Wählen Sie ein Datum aus' 
$objForm.Size = New-Object -TypeName System.Drawing.Size -ArgumentList (400, 400) 
$objForm.StartPosition = 'CenterScreen'
$objForm.KeyPreview = $True 

$objForm.Add_KeyDown({
    if ($_.KeyCode -eq 'Enter') 
    {
      $WahlDatum = $objCalendar.SelectionStart
      if ($WahlDatum)
      {
        Write-Host -Object "Ausgewähltes Datum: $WahlDatum"
      }
      $objForm.Close()
    }
})
$objForm.Add_KeyDown({
    if ($_.KeyCode -eq 'Escape') 
    {
      $objForm.Close()
    }
})
$objCalendar = New-Object -TypeName System.Windows.Forms.MonthCalendar 
$objCalendar.ShowTodayCircle = $False
$objCalendar.MaxSelectionCount = 1
$objForm.Controls.Add($objCalendar) 
[void]$objForm.ShowDialog() 
