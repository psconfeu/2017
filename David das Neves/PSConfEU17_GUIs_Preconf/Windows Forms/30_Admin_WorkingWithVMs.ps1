#http://techgenix.com/building-powershell-gui-part-13/

#Load Assemblies
[System.Reflection.Assembly]::LoadWithPartialName(“System.Windows.Forms”) | Out-Null
[System.Reflection.Assembly]::LoadWithPartialName(“System.Drawing”) | Out-Null
$net = New-Object -ComObject Wscript.Network
# Display the Main Screen
Function Display-MainScreen
{
$Form.Controls.Add($ListBox1)
$Form.Controls.Add($Button1)
$Form.Controls.Add($Button2)
$Form.Controls.Add($Label2)
}
# ———- Button Click Actions ——
#Define Return Button Click Function
Function Return-MainScreen
{
$Form.Controls.Remove($Label)
$Form.Controls.Remove($Label3)
$Form.Controls.Remove($Label4)
$Form.Controls.Remove($Label5)
$Form.Controls.Remove($Label6)
$Form.Controls.Remove($Label7)
$Form.Controls.Remove($Label8)
$Form.Controls.Remove($TextBox)
$Form.Controls.Remove($Button3)
$Form.Controls.Remove($Button4)
$Form.Controls.Remove($Button5)
$Form.Controls.Remove($Button6)
$Form.Refresh()
Display-MainScreen
}
#Define OK Button Click Function
Function Display-VMInfo($ChosenItem)
{
#Clear the window
$Form.Controls.Remove($ListBox1)
$Form.Controls.Remove($Label2)
$Form.Controls.Remove($Button1)
$Form.Controls.Remove($Button2)
$Form.Controls.Remove($Button5)
$Form.Controls.Remove($Button6)
$Form.Refresh()
#Create Output
Add-Type -AssemblyName System.Windows.Forms
# Get Virtual Machine Information
$SelectedVM = Get-VM $ChosenItem
$Global:Name = $SelectedVM.VMName
$State = $SelectedVM.State
$RunTime = $SelectedVM.UpTime
$Memory = $SelectedVM.MemoryAssigned
$CPU = $SelectedVM.ProcessorCount
$MemoryStart = ($SelectedVM.MemoryStartup / 1MB)
#Create text
$Label.Text = ‘Virtual Machine Name: ‘ + $Name
$Label4.Text = ‘VM State: ‘ + $State
$Label5.Text = ‘VM Up Time: ‘ + $RunTime
$Label6.Text = ‘Memory Assigned: ‘ + $Memory
$Label7.Text = ‘Virtual CPUs Assigned :’ + $CPU
$Global:TextBox.Text = $MemoryStart
#Display Screen Contents
$Form.Controls.Add($Label)
$Form.Controls.Add($Label4)
$Form.Controls.Add($Label5)
$Form.Controls.Add($Label6)
$Form.Controls.Add($Label7)
$Form.Controls.Add($Label3)
$Form.Controls.Add($Button3)
$Form.Controls.Add($Button4)
$Form.Controls.Add($Label8)
$Form.Controls.Add($TextBox)
If ($State -eq ‘Off’)
{
$Form.Controls.Add($Button5)
}
If ($State -EQ ‘Running’)
{
$Form.Controls.Add($Button6)
}
}
#—— Define All GUI Objects——-
# Define Label – This is a text box object that will display the VM Name
$Label = New-Object System.Windows.Forms.Label
$Label.AutoSize = $False
$Label.Location = new-object System.Drawing.Size(50,50)
$Label.Size = New-Object System.Drawing.Size(200,20)
$Label.ForeColor = “Black”
$label.BackColor = ‘White’
# Define Label2 – The Please Make a Selection Text
$Label2 = New-Object System.Windows.Forms.Label
$Label2.AutoSize = $True
$Label2.Location = new-object System.Drawing.Size(20,50)
$Label2.ForeColor = “DarkBlue”
$Label2.Text = “Please select a virtual machine from the list.”
# Define Label3 – The This is Your Selected Virtual Machine Text
$Label3 = New-Object System.Windows.Forms.Label
$Label3.AutoSize = $True
$Label3.Location = new-object System.Drawing.Size(50,30)
$Label3.ForeColor = “DarkBlue”
$Label3.Text = “Your selected virtual machine:”
# Define Label4 – The This is the VM State label
$Label4 = New-Object System.Windows.Forms.Label
$Label4.AutoSize = $False
$Label4.Location = new-object System.Drawing.Size(50,70)
$Label4.Size = New-Object System.Drawing.Size(200,20)
$Label4.ForeColor = “Black”
$Label4.BackColor = ‘White’
# Define Label5 – The This is the VM up time
$Label5 = New-Object System.Windows.Forms.Label
$Label5.AutoSize = $False
$Label5.Location = new-object System.Drawing.Size(50,90)
$Label5.Size = New-Object System.Drawing.Size(200,20)
$Label5.ForeColor = “Black”
$Label5.BackColor = “White”
# Define Label6 – The This is the VM memory assigned
$Label6 = New-Object System.Windows.Forms.Label
$Label6.AutoSize = $False
$Label6.Location = new-object System.Drawing.Size(50,110)
$Label6.Size = New-Object System.Drawing.Size(200,20)
$Label6.ForeColor = “Black”
$Label6.BackColor = ‘White’
# Define Label7 – The This is the VM virtual CPUs assigned
$Label7 = New-Object System.Windows.Forms.Label
$Label7.AutoSize = $False
$Label7.Location = new-object System.Drawing.Size(50,130)
$Label7.Size = New-Object System.Drawing.Size(200,20)
$Label7.ForeColor = “Black”
$Label7.BackColor = ‘White’
# Define Label8 – Memory Allocation Text
$Label8 = New-Object System.Windows.Forms.Label
$Label8.AutoSize = $False
$Label8.Location = new-object System.Drawing.Size(50,160)
$Label8.Size = New-Object System.Drawing.Size(200,20)
$Label8.ForeColor = “Black”
$Label8.Text = “Memory Allocation (MB)”
$Global:TextBox = New-Object System.Windows.Forms.TextBox
$Global:TextBox.Location = New-Object System.Drawing.Size(50,180)
$Global:TextBox.Size = New-Object System.Drawing.Size(200,20)
# Define List Box – This will display the virtual machines that can be selected
$ListBox1 = New-Object System.Windows.Forms.ListBox
$ListBox1.Location = New-Object System.Drawing.Size(20,80)
$ListBox1.Size = New-Object System.Drawing.Size(260,20)
$ListBox1.Height = 80
# This code populates the list box with virtual machine names
$VirtualMachines = Get-VM
ForEach ($VM in $VirtualMachines)
{
[void] $ListBox1.Items.Add($VM.Name)
}
# Define Button 1  – This is the selection screen’s OK button
$Button1 = new-object System.Windows.Forms.Button
$Button1.Location = new-object System.Drawing.Size(20,170)
$Button1.Size = new-object System.Drawing.Size(70,30)
$Button1.BackColor =”LightGray”
$Button1.Text = “OK”
$Button1.Add_Click({$ChosenItem=$ListBox1.SelectedItem;Display-VMInfo $ChosenItem})
# Define Button 2 – This is the selection screen’s Cancel button
$Button2 = New-Object System.Windows.Forms.Button
$Button2.Location = New-Object System.Drawing.Size(120,170)
$Button2.Size = New-Object System.Drawing.Size(70,30)
$Button2.BackColor =”LightGray”
$Button2.Text = “Cancel”
$Button2.Add_Click({$Form.Close()})
# Define Button 3 – This is the Return to Main Screen button
$Button3 = New-Object System.Windows.Forms.Button
$Button3.Location = New-Object System.Drawing.Size(50,220)
$Button3.Size = New-Object System.Drawing.Size(70,30)
$Button3.BackColor =”LightGray”
$Button3.Text = “Return”
$Button3.Add_Click({Return-MainScreen})
# Define Button 4 – This button doesn’t do anything yet, but we will use it eventually.
$Button4 = New-Object System.Windows.Forms.Button
$Button4.Location = New-Object System.Drawing.Size(140,220)
$Button4.Size = New-Object System.Drawing.Size(150,30)
$Button4.BackColor =”LightGray”
$Button4.Text = “Set Startup Memory”
$Button4.Add_Click({$MemoryStart = $TextBox.Text
$CmdStr = “Set-VMMemory ” + $Name +” -StartupBytes ” + $MemoryStart + “MB”
Invoke-Expression $CmdStr
Display-VMInfo $Name})
# Define Button 5 – This button will be used to start a virtual machine.
$Button5 = New-Object System.Windows.Forms.Button
$Button5.Location = New-Object System.Drawing.Size(140,260)
$Button5.Size = New-Object System.Drawing.Size(150,30)
$Button5.BackColor =”Green”
$Button5.ForeColor =”White”
$Button5.Text = “Start VM”
$Button5.Add_Click({Start-VM $Name | Display-VMInfo $Name})
# Define Button 6 – This button shuts down a virtual machine.
$Button6 = New-Object System.Windows.Forms.Button
$Button6.Location = New-Object System.Drawing.Size(140,260)
$Button6.Size = New-Object System.Drawing.Size(150,30)
$Button6.BackColor =”Red”
$Button6.ForeColor =”White”
$Button6.Text = “Stop VM”
$Button6.Add_Click({Stop-VM $Name -Force | Display-VMInfo $Name})
# ——– This is the end of the object definition section ——
# —–Draw the empty form—-
$Form = New-Object System.Windows.Forms.Form
$Form.width = 525
$Form.height = 350
$Form.BackColor = “lightblue”
$Form.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::Fixed3D
$Form.Text = “Hyper-V Virtual Machines”
$Form.maximumsize = New-Object System.Drawing.Size(525,350)
$Form.startposition = “centerscreen”
$Form.KeyPreview = $True
$Form.Add_KeyDown({if ($_.KeyCode -eq “Enter”) {}})
$Form.Add_KeyDown({if ($_.KeyCode -eq “Escape”)
{$Form.Close()}})
#—-Populate the form—-
Display-MainScreen
$Form.Add_Shown({$Form.Activate()})
$Form.ShowDialog()