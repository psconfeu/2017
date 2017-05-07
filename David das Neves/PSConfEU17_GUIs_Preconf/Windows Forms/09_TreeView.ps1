[reflection.assembly]::loadwithpartialname("System.Windows.Forms") | Out-Null
[reflection.assembly]::loadwithpartialname("System.Drawing") | Out-Null
$form1 = New-Object System.Windows.Forms.Form
$treeView1 = New-Object System.Windows.Forms.TreeView
$InitialFormWindowState = New-Object System.Windows.Forms.FormWindowState
$form1.Text = "Überschrift"
$form1.Name = "form1"
$form1.DataBindings.DefaultDataSourceUpdateMode = 0
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Width = 284
$System_Drawing_Size.Height = 262
$form1.ClientSize = $System_Drawing_Size
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Width = 260
$System_Drawing_Size.Height = 238
$treeView1.Size = $System_Drawing_Size
$treeView1.Name = "treeView1"
$System_Windows_Forms_TreeNode_1 = New-Object System.Windows.Forms.TreeNode
$System_Windows_Forms_TreeNode_2 = New-Object System.Windows.Forms.TreeNode
$System_Windows_Forms_TreeNode_3 = New-Object System.Windows.Forms.TreeNode
$System_Windows_Forms_TreeNode_3.Text = "SubSub"
$System_Windows_Forms_TreeNode_3.Name = "Knoten2"
$System_Windows_Forms_TreeNode_2.Nodes.Add($System_Windows_Forms_TreeNode_3)|Out-Null
$System_Windows_Forms_TreeNode_2.Text = "SubA"
$System_Windows_Forms_TreeNode_2.Name = "Knoten1"
$System_Windows_Forms_TreeNode_1.Nodes.Add($System_Windows_Forms_TreeNode_2)|Out-Null
$System_Windows_Forms_TreeNode_4 = New-Object System.Windows.Forms.TreeNode
$System_Windows_Forms_TreeNode_4.Text = "SubB"
$System_Windows_Forms_TreeNode_4.Name = "Knoten3"
$System_Windows_Forms_TreeNode_1.Nodes.Add($System_Windows_Forms_TreeNode_4)|Out-Null
$System_Windows_Forms_TreeNode_5 = New-Object System.Windows.Forms.TreeNode
$System_Windows_Forms_TreeNode_5.Text = "SubC"
$System_Windows_Forms_TreeNode_5.Name = "Knoten4"
$System_Windows_Forms_TreeNode_1.Nodes.Add($System_Windows_Forms_TreeNode_5)|Out-Null
$System_Windows_Forms_TreeNode_1.Text = "SubB"
$System_Windows_Forms_TreeNode_1.Name = "Knoten0"
$treeView1.Nodes.Add($System_Windows_Forms_TreeNode_1)|Out-Null
$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 12
$System_Drawing_Point.Y = 12
$treeView1.Location = $System_Drawing_Point
$treeView1.DataBindings.DefaultDataSourceUpdateMode = 0
$treeView1.TabIndex = 0
$form1.Controls.Add($treeView1)
$InitialFormWindowState = $form1.WindowState
$form1.add_Load($OnLoadForm_StateCorrection)
$form1.ShowDialog()| Out-Null
$treeView1.SelectedNode