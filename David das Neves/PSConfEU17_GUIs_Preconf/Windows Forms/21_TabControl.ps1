$null = [reflection.assembly]::loadwithpartialname('System.Windows.Forms')
$null = [reflection.assembly]::loadwithpartialname('System.Drawing')
$form1 = New-Object -TypeName System.Windows.Forms.Form
$statusBar1 = New-Object -TypeName System.Windows.Forms.StatusBar
$tabControl1 = New-Object -TypeName System.Windows.Forms.TabControl
$tabPage1 = New-Object -TypeName System.Windows.Forms.TabPage
$comboBox1 = New-Object -TypeName System.Windows.Forms.ComboBox
$tabPage2 = New-Object -TypeName System.Windows.Forms.TabPage
$button1 = New-Object -TypeName System.Windows.Forms.Button
$form1.Text = 'Reiter und Statusleiste'
$form1.Name = 'form1'
$form1.DataBindings.DefaultDataSourceUpdateMode = 0
$System_Drawing_Size = New-Object -TypeName System.Drawing.Size
$System_Drawing_Size.Width = 284
$System_Drawing_Size.Height = 262
$form1.ClientSize = $System_Drawing_Size
# Statusleiste anlegen und mit Ausgangswert (Text) belegen
$statusBar1.Name = 'statusBar1'
$statusBar1.Text = 'Auswahl: Noch nicht getroffen'
$System_Drawing_Size = New-Object -TypeName System.Drawing.Size
$System_Drawing_Size.Width = 284
$System_Drawing_Size.Height = 22
$statusBar1.Size = $System_Drawing_Size
$System_Drawing_Point = New-Object -TypeName System.Drawing.Point
$System_Drawing_Point.X = 0
$System_Drawing_Point.Y = 240
$statusBar1.Location = $System_Drawing_Point
$statusBar1.DataBindings.DefaultDataSourceUpdateMode = 0
$statusBar1.TabIndex = 1
$form1.Controls.Add($statusBar1)
# Auswahlreiter anlegen
$tabControl1.TabIndex = 0
$System_Drawing_Size = New-Object -TypeName System.Drawing.Size
$System_Drawing_Size.Width = 228
$System_Drawing_Size.Height = 162
$tabControl1.Size = $System_Drawing_Size
$System_Drawing_Point = New-Object -TypeName System.Drawing.Point
$System_Drawing_Point.X = 23
$System_Drawing_Point.Y = 35
$tabControl1.Location = $System_Drawing_Point
$tabControl1.DataBindings.DefaultDataSourceUpdateMode = 0
$tabControl1.Name = 'tabControl1'
$tabControl1.SelectedIndex = 0
$form1.Controls.Add($tabControl1)
# Auswahl Seite anlegen und an Auswahlreiter binden
$tabPage1.TabIndex = 0
$tabPage1.UseVisualStyleBackColor = $True
$System_Drawing_Size = New-Object -TypeName System.Drawing.Size
$System_Drawing_Size.Width = 220
$System_Drawing_Size.Height = 136
$tabPage1.Size = $System_Drawing_Size
$tabPage1.Text = 'Auswahlreiter'
$System_Drawing_Point = New-Object -TypeName System.Drawing.Point
$System_Drawing_Point.X = 4
$System_Drawing_Point.Y = 22
$tabPage1.Location = $System_Drawing_Point
$System_Windows_Forms_Padding = New-Object -TypeName System.Windows.Forms.Padding
$System_Windows_Forms_Padding.All = 3
$System_Windows_Forms_Padding.Bottom = 3
$System_Windows_Forms_Padding.Left = 3
$System_Windows_Forms_Padding.Right = 3
$System_Windows_Forms_Padding.Top = 3
$tabPage1.Padding = $System_Windows_Forms_Padding
$tabPage1.Name = 'tabPage1'
$tabPage1.DataBindings.DefaultDataSourceUpdateMode = 0
$tabControl1.Controls.Add($tabPage1)
# ComboBox auf Auswahltabseite kleben
$comboBox1.FormattingEnabled = $True
$System_Drawing_Size = New-Object -TypeName System.Drawing.Size
$System_Drawing_Size.Width = 121
$System_Drawing_Size.Height = 21
$comboBox1.Size = $System_Drawing_Size
$comboBox1.DataBindings.DefaultDataSourceUpdateMode = 0
$comboBox1.Name = 'comboBox1'
$null = $comboBox1.Items.Add('Eins')
$null = $comboBox1.Items.Add('Zwei')
$System_Drawing_Point = New-Object -TypeName System.Drawing.Point
$System_Drawing_Point.X = 18
$System_Drawing_Point.Y = 29
$comboBox1.Location = $System_Drawing_Point
$comboBox1.TabIndex = 0
$comboBox1.add_DropDownClosed({
    $statusBar1.Text = 'Auswahl: '+$comboBox1.SelectedItem
})
$tabPage1.Controls.Add($comboBox1)
# Beendenreiter anlegen
$tabPage2.TabIndex = 1
$tabPage2.UseVisualStyleBackColor = $True
$System_Drawing_Size = New-Object -TypeName System.Drawing.Size
$System_Drawing_Size.Width = 220
$System_Drawing_Size.Height = 136
$tabPage2.Size = $System_Drawing_Size
$tabPage2.Text = 'Beenden'
$System_Drawing_Point = New-Object -TypeName System.Drawing.Point
$System_Drawing_Point.X = 4
$System_Drawing_Point.Y = 22
$tabPage2.Location = $System_Drawing_Point
$System_Windows_Forms_Padding = New-Object -TypeName System.Windows.Forms.Padding
$System_Windows_Forms_Padding.All = 3
$System_Windows_Forms_Padding.Bottom = 3
$System_Windows_Forms_Padding.Left = 3
$System_Windows_Forms_Padding.Right = 3
$System_Windows_Forms_Padding.Top = 3
$tabPage2.Padding = $System_Windows_Forms_Padding
$tabPage2.Name = 'tabPage2'
$tabPage2.DataBindings.DefaultDataSourceUpdateMode = 0
$tabControl1.Controls.Add($tabPage2)
# Beenden Seite anlegen und an Beendenreiter binden
$button1.TabIndex = 0
$button1.Name = 'button1'
$System_Drawing_Size = New-Object -TypeName System.Drawing.Size
$System_Drawing_Size.Width = 75
$System_Drawing_Size.Height = 23
$button1.Size = $System_Drawing_Size
$button1.UseVisualStyleBackColor = $True
$button1.Text = 'Fertig'
$System_Drawing_Point = New-Object -TypeName System.Drawing.Point
$System_Drawing_Point.X = 28
$System_Drawing_Point.Y = 51
$button1.Location = $System_Drawing_Point
$button1.DataBindings.DefaultDataSourceUpdateMode = 0
$button1.add_Click({
    $form1.close()
    Write-Host -Object $comboBox1.SelectedItem
})
$tabPage2.Controls.Add($button1)
# Fenster anzeigen
$null = $form1.ShowDialog()