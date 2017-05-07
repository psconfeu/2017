########################################################################################
# JEA Helper Tool - Version 2.0
# By the Enterprise Cloud Group (ECG) CAT team
# Please send feedback to brunosa@microsoft.com
########################################################################################

    param (
    #[String]$SMAEndpointWS = "https://wap01.contoso.com",
    [String]$SMAEndpointWS = "",
    [String]$SMAEndpointPort = "9090"
    )

$ToolVersion = "2.0"
$Global:DefaultSDDL = "O:NSG:BAD:P(A;;GA;;;BA)(A;;GA;;;RM)S:P(AU;FA;GA;;;WD)(AU;SA;GXGW;;;WD)"
$DefaultPSSCFilesLocation = "C:\ProgramData\JEAConfiguration"

################################################
# Functions
################################################

function Popup()
{
param (
    [String]$Message
)

$a = new-object -comobject wscript.shell
$b = $a.popup($Message,0,"JEA Helper Tool",0)

}

Function ReloadPSRCListBox()
{
$FORM.FindName('RCListBox').Items.Clear()
$PSRCFiles = (Get-Item -Path "C:\Program Files\WindowsPowerShell" | Get-ChildItem -Recurse -Filter *.psrc)
foreach ($PSRCFile in $PSRCFiles)
    {
    $FORM.FindName('RCListBox').Items.Add($PSRCFile.FullName) | Out-Null
    }
}

Function ReloadPSSCListBox()
{
$FORM.FindName('SCGrid').ItemsSource = @()
$FORM.FindName('SCListBox').Items.Clear()
If ($FORM.FindName('ExcludeMSFTFromSCListBoxCB').IsChecked)
    {$PSSCList = Get-PSSessionConfiguration | ? Name -notmatch microsoft*}
    else
    {$PSSCList = Get-PSSessionConfiguration}

foreach ($PSSC in $PSSCList)
    {
    $FORM.FindName('SCListBox').Items.Add($PSSC.Name) | Out-Null
    }
}

Function AddArray()
{

    param (
    [String]$Module,
    [String]$Name,
    [String]$Parameter,
    [String]$ValidateSet = "",
    [String]$ValidatePattern = ""
    )
    
    $Global:CommandArray = @()
    $tmpObject = select-object -inputobject "" IsChecked, Module, Name, Parameter, ValidateSet, ValidatePattern
    $tmpObject.Ischecked = $false
    $tmpObject.Module = $Module
    $tmpObject.Name = $Name
    $tmpObject.Parameter = $Parameter
    $tmpObject.ValidateSet = $ValidateSet
    $tmpObject.ValidatePattern = $ValidatePattern
    $Global:CommandArray += $tmpObject
    If ($FORM.FindName('CSVGrid').Items.Count -eq 0)
    {$FORM.FindName('CSVGrid').ItemsSource = $Global:CommandArray}
    else {$FORM.FindName('CSVGrid').ItemsSource += $Global:CommandArray}
}

Function UpdateCmdletList()
{
    $FORM.FindName('PickCmdletComboBox').Items.Clear()
    Foreach ($CmdletItem in $Global:CmdletList)
        { If ($CmdletItem.Name.Length -gt 3) {$FORM.FindName('PickCmdletComboBox').Items.Add($CmdletItem.Name) | out-null} }
}

Function UpdateModuleList()
{
$FORM.FindName('FilterModuleComboBox').Items.Clear()
write-host -ForegroundColor white "["(date -format "HH:mm:ss")"] Loading modules list...This may take a few seconds, please wait..."
#$ModuleList = Get-Module | Sort-Object Name | Select Name
$ModuleList = Get-Module -ListAvailable | Sort-Object Name | Select Name
Foreach ($ModuleItem in $ModuleList)
    { If ($ModuleList.Name.Length -gt 3) {$FORM.FindName('FilterModuleComboBox').Items.Add($ModuleItem.Name) | out-null} }
}

Function UpdateScriptOutput()
{
    If ($FORM.FindName('CSVGrid').ItemsSource.Count -gt 0)
        {

        #Cleanup duplicates in source grid

        #write-host -ForegroundColor white "["(date -format "HH:mm:ss")"] Scanning grid for duplicates before updating role capability output..."
        $TempArray = @()
        Foreach ($CurrentRow in $FORM.FindName('CSVGrid').ItemsSource)
            {
            $AddRow = $true
            If ((($FORM.FindName('CSVGrid').Itemssource | ? Name -eq $CurrentRow.Name).Count -gt 1) -and ($CurrentRow.Parameter -eq "") -and ($CurrentRow.Name -ne ""))
                {
                #This cmdlet is here without any parameters and has duplicates with the same cmdlet name
                If (($FORM.FindName('CSVGrid').Itemssource | ? Name -eq $CurrentRow.Name | ? Parameter -ne "") -ne $null)
                    #This cmdlet is here without any parameters, and is also in the grid with some parameters, only the row with parameter details should be kept
                    {
                    write-host -ForegroundColor gray "["(date -format "HH:mm:ss")"] -- "$CurrentRow.Name "will be removed from the grid as duplicate - there is at least another row with parameter"
                    $AddRow = $false
                    }
                    else
                    #There are no other rows with parameters for the same cmdlet, but there may be other rows already added for the same cmdlet, with or without any parameters
                    {
                    If ((($TempArray | ? Name -eq $CurrentRow.Name).Count -gt 0) -or (($TempArray | ? Name -eq $CurrentRow.Name) -ne $null))
                        #We already included this cmdlet in the new non-duplicate list, there is no need to add it again
                        {
                        If ( -not  (($CurrentRow.Name.Contains("*")) -and ($CurrentRow.Module -ne "")))
                            {
                            write-host -ForegroundColor gray "["(date -format "HH:mm:ss")"] -- "$CurrentRow.Name "will be removed from the grid as duplicate - another entry has already been kept"
                            $AddRow = $false
                            }
                        }
                    }
                }
            If ($AddRow -eq $True)
                {
                $tmpObject = select-object -inputobject "" IsChecked, Module, Name, Parameter, ValidateSet, ValidatePattern
                $tmpObject.Ischecked = $false
                $tmpObject.Module = $CurrentRow.Module
                $tmpObject.Name = $CurrentRow.Name
                $tmpObject.Parameter = $CurrentRow.Parameter
                $tmpObject.ValidateSet = $CurrentRow.ValidateSet
                $tmpObject.ValidatePattern = $CurrentRow.ValidatePattern
                If (($tmpObject.ValidatePattern -ne "") -and ($tmpObject.ValidateSet -ne ""))
                    {
                    $tmpObject.ValidateSet = ""
                    write-host -ForegroundColor gray "["(date -format "HH:mm:ss")"] -- "$CurrentRow.Name "had both ValidatePattern and ValidateSet options used. Patterns supersede Sets, so the ValidateSet cell has been cleared."
                    }
                If (($tmpObject.Module -ne "") -and ($tmpObject.Name -eq ""))
                    {
                    $tmpObject.Name = "*"
                    write-host -ForegroundColor gray "["(date -format "HH:mm:ss")"] -- "$CurrentRow.Module "row was corrected to include all cmdlets for this module (name column was empty)"
                    }
                $TempArray += $tmpObject
                }
            }
        $FORM.FindName('CSVGrid').ItemsSource = $TempArray
        #write-host -ForegroundColor white "["(date -format "HH:mm:ss")"] Scanning grid for duplicates before updating role capability output...done!"

        #Update output
        $NewScriptContent = ""
        $VisibleCmdletsOutput = ""
        $VisibleFunctionsOutput = ""
        Foreach ($CurrentRow in $FORM.FindName('CSVGrid').ItemsSource)
            {
            #Only process rows with meaningful data
            If (($CurrentRow.Module -ne "") -or ($CurrentRow.Name -ne ""))
                {
                If ($CurrentRow.Module -eq "")
                    {
                    #Name row - we should only process it it it has not been added to the output already (since we combine the different parameters)
                    If ($VisibleCmdletsOutput.Contains($CurrentRow.Name.Trim()) -eq $False)
                        {
                        $FirstParam = $True
                        $CurrentCmdletOutput = "@{Name ='" + $CurrentRow.Name.Trim() + "';"
                        foreach ($CmdletData in ($FORM.FindName('CSVGrid').ItemsSource | ? Name -eq $CurrentRow.Name))
                            {
                            #write-host $CmdletData
                            If ($CmdletData.Parameter -ne "")
                                {
                                If ($FirstParam -eq $True)
                                    {
                                    $CurrentCmdletOutput+= " Parameters=@{Name='" + $CmdletData.Parameter.Trim() + "'"
                                    $FirstParam = $False
                                    }
                                    else
                                    {
                                    $CurrentCmdletOutput+= " @{Name='" + $CmdletData.Parameter.Trim() + "'"
                                    }
                                }
                            If ($CmdletData.ValidateSet -ne "")
                                {
                                $CurrentCmdletOutput+= "; ValidateSet=" + $CmdletData.ValidateSet.Trim()
                                }
                            If ($CmdletData.ValidatePattern -ne "")
                                {
                                $CurrentCmdletOutput+= "; ValidatePattern=" + $CmdletData.ValidatePattern.Trim()
                                }
                            $CurrentCmdletOutput+= "}, "
                            }
                        $CurrentCmdletOutput = $CurrentCmdletOutput.TrimEnd(", ")
                        $CurrentCmdletOutput += " },"
                         If ($CurrentCmdletOutput -eq ( "@{Name ='" + $CurrentRow.Name.Trim() + "';} },"))
                            #No parameters were specified in the grid for this cmdlet, we can simplify the syntaz
                            {
                            $CurrentCmdletOutput = "'" + $CmdletData.Name.Trim() + "',"
                            }
                        $CurrentCommandType = (Get-Command -Name $CurrentRow.Name -ErrorAction SilentlyContinue).CommandType
                        If (($CurrentCommandType -eq "Function") -and ($CurrentCommandType.Count -eq 1) -and ($CurrentCommandType -ne $null))
                            #Adding to the right output section
                            {
                            $VisibleFunctionsOutput+=$CurrentCmdletOutput + "`r`n" 
                            write-host -ForegroundColor gray "["(date -format "HH:mm:ss")"] -- INFORMATION:" $CurrentRow.Name "was added to VisibleFunctions section"
                            }
                            else
                            {
                            $VisibleCmdletsOutput+=$CurrentCmdletOutput + "`r`n"    
                            If ($CurrentCommandType -eq $null)
                                {write-host -ForegroundColor red "["(date -format "HH:mm:ss")"] -- WARNING:" $CurrentRow.Name "was added to VisibleCmdlets section because the command is not found locally and the command type could not be determined. While this should not be an issue when running the configuration, it is not considered a best practice."}
                            }
                        }
                    }
                    else
                    {
                    If ($CurrentRow.Name -eq "")
                        #Module row
                        {
                        $VisibleCmdletsOutput+= "'" + $CurrentRow.Module.Trim() + "\*',`r`n"
                        }
                        else
                        #Module-Name row
                        {
                        $CurrentCommandType = (Get-Command -Name $CurrentRow.Name -ErrorAction SilentlyContinue).CommandType
                        If (($CurrentCommandType -eq "Function") -and ($CurrentCommandType.Count -eq 1))
                            #Adding to the right output
                            {
                            $VisibleFunctionsOutput+= "'" + $CurrentRow.Module.Trim() + "\" + $CurrentRow.Name.Trim() + "',`r`n"
                            write-host -ForegroundColor gray "["(date -format "HH:mm:ss")"] -- INFORMATION:" $CurrentRow.Name "was added to VisibleFunctions section"
                            }
                            else
                            {
                            $VisibleCmdletsOutput+= "'" + $CurrentRow.Module.Trim() + "\" + $CurrentRow.Name.Trim() + "',`r`n"
                            If ($CurrentCommandType -eq $null)
                                {write-host -ForegroundColor red "["(date -format "HH:mm:ss")"] -- WARNING:" $CurrentRow.Name "was added to VisibleCmdlets section because the command is not found locally and the command type could not be determined. While this should not be an issue when running the configuration, it is not considered a best practice."}
                            }
                        }
                    }
                }
            }
        $VisibleCmdletsOutput = $VisibleCmdletsOutput.TrimEnd(",`r`n")
        $VisibleFunctionsOutput = $VisibleFunctionsOutput.TrimEnd(",`r`n")
        $FORM.FindName('ScriptOutputTextBlock').Text="VisibleCmdlets=" + $VisibleCmdletsOutput + "`r`n" + "`r`n" + "VisibleFunctions=" + $VisibleFunctionsOutput
        }
        else
        {
        $FORM.FindName('ScriptOutputTextBlock').Text="Script output will be updated here"
        }
}

################################################
# Form definition
################################################

Add-Type -AssemblyName PresentationFramework
Add-Type -AssemblyName System.Windows.Forms

[XML]$XAML = @'
<Window
        xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        ResizeMode="NoResize"
        Title="JEA Helper Tool" Height="730" Width="840">

        <Window.Resources>
            <Style TargetType="{x:Type TabItem}">
                <Setter Property="Template">
                    <Setter.Value>
                        <ControlTemplate TargetType="{x:Type TabItem}">
                            <Grid>
                                <Border Name="Border" Background="LightBlue" BorderBrush="Black" BorderThickness="1,1,1,0" CornerRadius="25,25,0,0" >
                                        <ContentPresenter x:Name="ContentSite" VerticalAlignment="Center" HorizontalAlignment="Center" ContentSource="Header" Margin="12,2,12,2"/>
                                </Border>
                            </Grid>
                            <ControlTemplate.Triggers>
                                <Trigger Property="IsSelected" Value="True">
                                    <Setter TargetName="Border" Property="Background" Value="LightBlue" />
                                </Trigger>
                                <Trigger Property="IsSelected" Value="False">
                                    <Setter TargetName="Border" Property="Background" Value="White" />
                                </Trigger>
                            </ControlTemplate.Triggers>
                        </ControlTemplate>
                    </Setter.Value>
                </Setter>
            </Style>
    </Window.Resources>

    <Grid>
        <TabControl>
            <TabItem>
                <TabItem.Header>
                    <StackPanel Orientation="Horizontal">
                        <TextBlock Text="Create or Edit Role Capability" Margin="2,0,0,0" VerticalAlignment="Center" />
                    </StackPanel>
                </TabItem.Header>
                <Grid>
                    <Grid.RowDefinitions>
                        <RowDefinition Height="30"/>
                        <RowDefinition Height="30"/>
                        <RowDefinition Height="30"/>
                        <RowDefinition Height="30"/>
                        <RowDefinition Height="30"/>
                        <RowDefinition Height="30"/>
                        <RowDefinition Height="450"/>
                        <RowDefinition Height="30"/>
                    </Grid.RowDefinitions>
                    <Label Content="In this tab, you can create or open a Role Capability - it can then be edited in the next tabs" IsEnabled="True" Grid.Row="0" HorizontalAlignment="Left" VerticalAlignment="Center" Margin="5,0,0,0" Width="500"></Label>
                    <Label FontWeight="Bold" Content="Create New Role Capability" IsEnabled="True" Grid.Row="1" HorizontalAlignment="Left" VerticalAlignment="Center" Margin="5,0,0,0" Width="280"></Label>
                    <Label Content="Role Capability Name" HorizontalAlignment="Left" VerticalAlignment="Center"  Margin="5,0,0,0" Grid.Row="2"></Label> 
                    <TextBox Text="Demo_RC" Name="NewRoleCapabilityNameTextBox" IsEnabled="True" Grid.Row="2" HorizontalAlignment="Left" VerticalAlignment="Center" Margin="200,0,0,0" Width="100"></TextBox>
                    <Label Content="Module Name" HorizontalAlignment="Left" VerticalAlignment="Center"  Margin="350,0,0,0" Grid.Row="2"></Label> 
                    <TextBox Text="DemoXYZ" Name="NewRoleCapabilityModuleTextBox" IsEnabled="True" Grid.Row="2" HorizontalAlignment="Left" VerticalAlignment="Center" Margin="500,0,0,0" Width="100"></TextBox>
                    <Label Content="Author" HorizontalAlignment="Left" VerticalAlignment="Center"  Margin="5,0,0,0" Grid.Row="3"></Label> 
                    <TextBox Text="brunosa" Name="NewRoleCapabilityAuthorTextBox" IsEnabled="True" Grid.Row="3" HorizontalAlignment="Left" VerticalAlignment="Center" Margin="200,0,0,0" Width="100"></TextBox>
                    <Label Content="Company" HorizontalAlignment="Left" VerticalAlignment="Center"  Margin="350,0,0,0" Grid.Row="3"></Label> 
                    <TextBox Text="CONTOSO" Name="NewRoleCapabilityCompanyTextBox" IsEnabled="True" Grid.Row="3" HorizontalAlignment="Left" VerticalAlignment="Center" Margin="500,0,0,0" Width="100"></TextBox>
                    <Button Content="Create" Name="CreateRoleCapabilityButton" IsEnabled="True" Visibility="visible" HorizontalAlignment="Left" VerticalAlignment="Center" Margin="700,0,0,0" Width="110" Grid.Row="3"/>
                    <Label FontWeight="Bold" Content="Open Existing New Role Capability" IsEnabled="True" Grid.Row="4" HorizontalAlignment="Left" VerticalAlignment="Center" Margin="5,0,0,0" Width="280"></Label>
                    <ComboBox Margin="5,0,0,0" Name="RCListBox" HorizontalAlignment="Left" VerticalAlignment="Center" Width="560" Grid.Row="5"/>
                    <Button Content="Refresh List" Name="RefreshRCList" IsEnabled="True" Visibility="visible" HorizontalAlignment="Left" VerticalAlignment="Center" Margin="570,0,0,0" Width="120" Grid.Row="5"/>
                    <Button Content="Browse..." Name="OpenRoleCapabilityButton" IsEnabled="True" Visibility="visible" HorizontalAlignment="Left" VerticalAlignment="Center" Margin="700,0,0,0" Width="110" Grid.Row="5"/>
                    <TextBox Name="PSRCTextBlock" TextWrapping="Wrap" AcceptsReturn="True" VerticalScrollBarVisibility="Visible"  Margin="5,0,0,0" Grid.Row="6">
                        Role Capability file will be displayed here
                    </TextBox>
                    <Label Name="PSRCPathLabel" Content="No PSRC file open right now" HorizontalAlignment="Left" IsEnabled="False" VerticalAlignment="Center"  Margin="5,0,0,0" Grid.Row="7"></Label> 
                    <Button Content="Save any changes" Name="SaveRoleCapabilityButton" IsEnabled="True" Visibility="visible" HorizontalAlignment="Left" VerticalAlignment="Center" Margin="550,0,0,0" Width="120" Grid.Row="7"/>
                    <Button Content="Copy to Clipboard" Name="CopyToClipboard" Visibility="visible" HorizontalAlignment="Left" VerticalAlignment="Center" Margin="700,0,0,0" Width="110" Grid.Row="7"/>
                 </Grid>
            </TabItem>
             <TabItem>
                <TabItem.Header>
                    <StackPanel Orientation="Horizontal">
                         <TextBlock Text="Role Capabilities Design" Margin="2,0,0,0" VerticalAlignment="Center" />
                    </StackPanel>
                </TabItem.Header>
                <Grid>
                    <Grid.RowDefinitions>
                        <RowDefinition Height="30"/>
                        <RowDefinition Height="45"/>
                        <RowDefinition Height="45"/>
                        <RowDefinition Height="40"/>
                        <RowDefinition Height="40"/>
                        <RowDefinition Height="40"/>
                        <RowDefinition Height="220"/>
                        <RowDefinition Height="30"/>
                        <RowDefinition Height="130"/>
                        <RowDefinition Height="30"/>
                    </Grid.RowDefinitions>

                    <Label Content="In this tab, you can create the VisibleCmdlets section of Role Capabilities, and copy/paste them in your files or the first tab" HorizontalAlignment="Left" VerticalAlignment="Center"  Margin="5,0,0,0" Grid.Row="0"></Label> 
                    <Label Content="You can start from..." HorizontalAlignment="Left" VerticalAlignment="Center"  Margin="5,0,0,0" Grid.Row="1"></Label> 
                    <Button Content="Existing role capability..." Name="OpenExistingPSRCFile" Visibility="visible" HorizontalAlignment="Left" VerticalAlignment="Center" Margin="230,0,0,0" Width="150" Grid.Row="1"/>
                    <Button Content="Audit log" Name="ImportAuditLog" Visibility="visible" HorizontalAlignment="Left" VerticalAlignment="Center" Margin="400,0,0,0" Width="110" Grid.Row="1"/>
                    <ComboBox Name="ImportCSVFileAction" HorizontalAlignment="Left" VerticalAlignment="Center" Margin="530,0,0,0" Width="110" Grid.Row="1"></ComboBox>
                    <Label HorizontalAlignment="Left" Margin="5,0,0,0" MaxWidth="170" Grid.Row="2">  
                        <TextBlock Name="PickCmdletLabel" Text="Or you can pick a cmdlet and - optionally - properties" TextWrapping= "Wrap"></TextBlock>  
                    </Label> 
                    <ComboBox Name="PickCmdletComboBox" IsEditable="False" HorizontalAlignment="Left" VerticalAlignment="Center" Width="215" Margin="230,0,0,0" Grid.Row="2"></ComboBox>
                    <ComboBox Name="PickPropertiesComboBox" HorizontalAlignment="Left" VerticalAlignment="Center" Width="215" Margin="475,0,0,0" Grid.Row="2">
                        <ComboBox.ItemTemplate>
                            <DataTemplate>
                                <StackPanel Orientation="Horizontal">
                                    <CheckBox Margin="5" IsChecked="{Binding PropertyChecked}"/>
                                    <TextBlock Margin="5" Text="{Binding PropertyName}"/>
                                </StackPanel>
                            </DataTemplate>
                        </ComboBox.ItemTemplate>
                    </ComboBox>
                    <Button Content="Add to Grid" Name="AddToGrid" VerticalAlignment="Center" HorizontalAlignment="Left" Margin="710,0,0,0" Width="100" Grid.Row="2"/>
                    <Label HorizontalAlignment="Left" Margin="5,0,0,0" MaxWidth="210" Grid.Row="3" Grid.RowSpan="2">  
                        <TextBlock Name="PickModuleLabel" Text="Or you can add a full/partial module, or use it to filter the cmdlets list" TextWrapping= "Wrap"></TextBlock>  
                    </Label> 
                    <ComboBox Name="FilterModuleComboBox" IsEditable="False" HorizontalAlignment="Left" VerticalAlignment="Center" Width="120" Margin="230,0,0,0" Grid.Row="3"></ComboBox>
                    <Button Content="Add to Grid" Name="AddModuleFullToGridButton" Visibility="visible" HorizontalAlignment="Left" VerticalAlignment="Center" Margin="365,0,0,0" Width="100" Grid.Row="3"/>
                    <Button Content="Add Get-* only" Name="AddModuleGetToGridButton" Visibility="visible" HorizontalAlignment="Left" VerticalAlignment="Center" Margin="480,0,0,0" Width="100" Grid.Row="3"/>
                    <Button Content="Filter Cmdlets" Name="FilterModuleButton" Visibility="visible" HorizontalAlignment="Left" VerticalAlignment="Center" Margin="595,0,0,0" Width="100" Grid.Row="3"/>
                    <Button Content="Remove Filter" Name="RemoveFilterModuleButton" Visibility="visible" HorizontalAlignment="Left" VerticalAlignment="Center" Margin="710,0,0,0" Width="100" Grid.Row="3"/>
                    <Label Content="Module to import" HorizontalAlignment="Left" VerticalAlignment="Center" Margin="230,0,0,0" Grid.Row="4"></Label>
                    <TextBox Text="" Name="ImportModuleTextBox" HorizontalAlignment="Left" VerticalAlignment="Center" Width="215" Margin="365,0,0,0" Grid.Row="4"></TextBox>
                    <Button Content="Import Module" Name="ImportModuleButton" Visibility="visible" HorizontalAlignment="Left" VerticalAlignment="Center" Margin="595,0,0,0" Width="100" Grid.Row="4"/>

                    <Label Name="PickRunbookLabelContainer" VerticalAlignment="Center" HorizontalAlignment="Left" Margin="5,0,0,0" MaxWidth="230" Grid.Row="5">  
                        <TextBlock Name="PickRunbookLabel" Text="Or you can pick SMA Runbook(s)" TextWrapping= "Wrap"></TextBlock>  
                    </Label> 
                    <ComboBox Name="PickRunbooksComboBox" HorizontalAlignment="Left" VerticalAlignment="Center" Width="460" Margin="230,0,0,0" Grid.Row="5">
                        <ComboBox.ItemTemplate>
                            <DataTemplate>
                                <StackPanel Orientation="Horizontal">
                                    <CheckBox Margin="5" IsChecked="{Binding RunbookChecked}"/>
                                    <TextBlock Margin="5" Text="{Binding RunbookName}"/>
                                </StackPanel>
                            </DataTemplate>
                        </ComboBox.ItemTemplate>
                    </ComboBox>
                    <Button Content="Add to Grid" Name="AddRunbookToGrid" VerticalAlignment="Center" HorizontalAlignment="Left" Margin="710,0,0,0" Width="100" Grid.Row="5"/>

                    <DataGrid AutoGenerateColumns="False" Margin="10,0,0,0" Name="CSVGrid" HorizontalAlignment="Left" VerticalAlignment="Top" Height="220" Width="800" ItemsSource="{Binding}" SelectionUnit="Cell" Grid.Row="6">
                        <DataGrid.Columns>
                            <DataGridCheckBoxColumn Binding="{Binding Path=IsChecked}"/>
                            <DataGridTextColumn Binding="{Binding Path=Module}" Header="Module"/>
                            <DataGridTextColumn Binding="{Binding Path=Name}" Header="Name"/>
                            <DataGridTextColumn Binding="{Binding Path=Parameter}" Header="Parameter" />
                            <DataGridTextColumn Binding="{Binding Path=ValidateSet}">
                                <DataGridTextColumn.Header>
                                    <TextBlock Text="ValidateSet" ToolTipService.ToolTip="Colon separated list of allowed parameters in single quotes( e.g. 'Item1', 'Item2'). An empty list means that all parameters are allowed." />
                                </DataGridTextColumn.Header>
                                <DataGridTextColumn.ElementStyle>
                                    <Style TargetType="{x:Type TextBlock}">
                                        <Setter Property="ToolTip" Value="{Binding Description}" />
                                        <Setter Property="TextWrapping" Value="Wrap" />
                                    </Style>
                                </DataGridTextColumn.ElementStyle>
                            </DataGridTextColumn>  
                            <DataGridTextColumn Binding="{Binding Path=ValidatePattern}">
                                <DataGridTextColumn.Header>
                                    <TextBlock Text="ValidatePattern" ToolTipService.ToolTip="A regular expression in single quotes (e.g. 'L*'). This is an optional parameter. See examples here : http://technet.microsoft.com/en-us/library/hh847880.aspx" />
                                </DataGridTextColumn.Header>
                                <DataGridTextColumn.ElementStyle>
                                    <Style TargetType="{x:Type TextBlock}">
                                        <Setter Property="ToolTip" Value="{Binding Description}" />
                                        <Setter Property="TextWrapping" Value="Wrap" />
                                     </Style>
                                </DataGridTextColumn.ElementStyle>
                            </DataGridTextColumn>  
                        </DataGrid.Columns>
                    </DataGrid> 
                    <Button Content="Add Row" Name="AddRowGrid" Visibility="visible" HorizontalAlignment="Left" VerticalAlignment="Center" Margin="70,0,0,0" Width="150" Grid.Row="7"/>
                    <Button Content="Remove Selected Row(s)" Name="DeleteRowGrid" Visibility="visible" HorizontalAlignment="Left" VerticalAlignment="Center" Margin="230,0,0,0" Width="150" Grid.Row="7"/>
                    <Button Content="Remove All Rows" Name="DeleteAllRows" Visibility="visible" HorizontalAlignment="Left" VerticalAlignment="Center" Margin="390,0,0,0" Width="150" Grid.Row="7"/>
                    <Button Content="Refresh Role Capability Output" Name="RefreshScriptOutput" Visibility="visible" HorizontalAlignment="Left" VerticalAlignment="Center" Margin="550,0,0,0" Width="180" Grid.Row="7"/>

                    <TextBox Name="ScriptOutputTextBlock" TextWrapping="Wrap" AcceptsReturn="True" VerticalScrollBarVisibility="Visible" HorizontalAlignment="Left" Margin="10,0,0,0" Width="800" Grid.Row="8">
                        VisibleCmdlets and VisibleFunctions output will be updated here
                    </TextBox>
                    <Button Content="Copy to Clipboard" Name="CopyToClipboard2" Visibility="visible" HorizontalAlignment="Left" VerticalAlignment="Center" Margin="690,0,0,0" Width="120" Grid.Row="9"/>
               </Grid>
            </TabItem>
            <TabItem>
                <TabItem.Header>
                    <StackPanel Orientation="Horizontal">
                        <TextBlock Text="Configurations Listing, Mapping and Testing" Margin="2,0,0,0" VerticalAlignment="Center" />
                    </StackPanel>
                </TabItem.Header>
                <Grid>
                    <Grid.RowDefinitions>
                        <RowDefinition Height="30"/>
                        <RowDefinition Height="30"/>
                        <RowDefinition Height="30"/>
                        <RowDefinition Height="30"/>
                        <RowDefinition Height="30"/>
                        <RowDefinition Height="30"/>
                        <RowDefinition Height="30"/>
                        <RowDefinition Height="30"/>
                        <RowDefinition Height="30"/>
                        <RowDefinition Height="30"/>
                        <RowDefinition Height="30"/>
                        <RowDefinition Height="30"/>
                        <RowDefinition Height="30"/>
                        <RowDefinition Height="30"/>
                        <RowDefinition Height="30"/>
                    </Grid.RowDefinitions>
                    <Label FontWeight="Bold" Content="View and Work with Existing Session Configurations" IsEnabled="True" Grid.Row="0" HorizontalAlignment="Left" VerticalAlignment="Center" Margin="5,0,0,0" Width="400"></Label>
                    <ListBox Margin="5,0,0,0" Name="SCListBox" HorizontalAlignment="Left" VerticalAlignment="Top" Width="194" Height="120" Grid.Row="1" Grid.RowSpan="4"/>
                    <DataGrid AutoGenerateColumns="False" Margin="300,0,0,0" Name="SCGrid" HorizontalAlignment="Left" VerticalAlignment="Top" Height="120" Width="300" ItemsSource="{Binding}" SelectionUnit="Cell" Grid.Row="1" Grid.RowSpan="4">
                        <DataGrid.Columns>
                            <DataGridCheckBoxColumn Binding="{Binding Path=IsChecked}"/>
                            <DataGridTextColumn Binding="{Binding Path=UserGroup}" Header="User or Group"/>
                            <DataGridTextColumn Binding="{Binding Path=RoleCapability}" Header="Role Capability"/>
                        </DataGrid.Columns>
                    </DataGrid> 
                    <CheckBox Name="ExcludeMSFTFromSCListBoxCB" IsEnabled="True" IsChecked="True" HorizontalAlignment="Left" VerticalAlignment="Center" Margin="5,0,0,0" Grid.Row="5"></CheckBox>
                    <Label Name="ExcludeMSFTFromSCListBoxLabel" IsEnabled="True" Content="Exclude microsoft.* session configurations" HorizontalAlignment="Left" VerticalAlignment="Center" Margin="25,0,0,0" Grid.Row="5"></Label>    
                    <Button Content="Test" Name="TestToolkit" IsEnabled="True" Visibility="visible" HorizontalAlignment="Left" VerticalAlignment="Center" Margin="205,0,0,0" Width="80" Grid.Row="1"/>
                    <Button Content="Unregister" Name="UnregisterSCButton" IsEnabled="True" Visibility="visible" HorizontalAlignment="Left" VerticalAlignment="Center" Margin="205,0,0,0" Width="80" Grid.Row="2"/>
                    <Button Content="Refresh" Name="ReloadSCListBox" IsEnabled="True" Visibility="visible" HorizontalAlignment="Left" VerticalAlignment="Center" Margin="205,0,0,0" Width="80" Grid.Row="3"/>

                    <Button Content="Resultant Set for Selected Row" Name="RSOPSCGrid" Visibility="visible" HorizontalAlignment="Left" VerticalAlignment="Center" Margin="605,0,0,0" Width="170" Grid.Row="1"/>
                    <Button Content="Add Row" Name="AddRowSCGrid" Visibility="visible" HorizontalAlignment="Left" VerticalAlignment="Center" Margin="605,0,0,0" Width="170" Grid.Row="2"/>
                    <Button Content="Remove Selected Row(s)" Name="DeleteRowSCGrid" Visibility="visible" HorizontalAlignment="Left" VerticalAlignment="Center" Margin="605,0,0,0" Width="170" Grid.Row="3"/>
                    <Button Content="Remove All Rows" Name="DeleteAllRowsSCGrid" Visibility="visible" HorizontalAlignment="Left" VerticalAlignment="Center" Margin="605,0,0,0" Width="170" Grid.Row="4"/>
                    <Button Content="Save and Re-register Configuration (overwrite)" Name="SaveEditedSCGrid" Visibility="visible" HorizontalAlignment="Left" VerticalAlignment="Center" Margin="300,0,0,0" Width="300" Grid.Row="5"/>



                    <Label FontWeight="Bold" Content="Create New Session Configuration" IsEnabled="True" Grid.Row="8" HorizontalAlignment="Left" VerticalAlignment="Center" Margin="5,0,0,0" Width="280"></Label>
                    <Label Content="Name for new Session Configuration" HorizontalAlignment="Left" VerticalAlignment="Center" Margin="5,0,0,0" Grid.Row="9"></Label>
                    <TextBox Text="JEA_DemoXYZ" Name="NewSCName" HorizontalAlignment="Left" VerticalAlignment="Center" Width="215" Margin="5,0,0,0" Grid.Row="10"></TextBox>
                    <Label Content="Session Configuration Files Location" HorizontalAlignment="Left" VerticalAlignment="Center" Margin="5,0,0,0" Grid.Row="11"></Label>
                    <TextBox Text="C:\ProgramData\JEAConfiguration" Name="PSSCFilesLocationTextBox" HorizontalAlignment="Left" VerticalAlignment="Center" Width="215" Margin="5,0,0,0" Grid.Row="12"></TextBox>
                    <Button Content="Open Location" Name="OpenNewSCLocation" Visibility="visible" HorizontalAlignment="Left" VerticalAlignment="Center" Margin="5,0,0,0" Width="130" Grid.Row="13"/>

                    <DataGrid AutoGenerateColumns="False" Margin="300,0,0,0" Name="NewSCGrid" HorizontalAlignment="Left" VerticalAlignment="Top" Height="150" Width="300" ItemsSource="{Binding}" SelectionUnit="Cell" Grid.Row="9" Grid.RowSpan="5">
                        <DataGrid.Columns>
                            <DataGridCheckBoxColumn Binding="{Binding Path=IsChecked}"/>
                            <DataGridTextColumn Binding="{Binding Path=UserGroup}" Header="User or Group"/>
                            <DataGridTextColumn Binding="{Binding Path=RoleCapability}" Header="Role Capability"/>
                        </DataGrid.Columns>
                    </DataGrid> 
                    <Button Content="Add Row" Name="AddRowNewSCGrid" Visibility="visible" HorizontalAlignment="Left" VerticalAlignment="Center" Margin="605,0,0,0" Width="170" Grid.Row="9"/>
                    <Button Content="Remove Selected Row(s)" Name="DeleteRowNewSCGrid" Visibility="visible" HorizontalAlignment="Left" VerticalAlignment="Center" Margin="605,0,0,0" Width="170" Grid.Row="10"/>
                    <Button Content="Remove All Rows" Name="DeleteAllRowsNewSCGrid" Visibility="visible" HorizontalAlignment="Left" VerticalAlignment="Center" Margin="605,0,0,0" Width="170" Grid.Row="11"/>
                    <Button Content="Replace w/ PSSC File Data..." Name="OpenExistingPSSCFile" Visibility="visible" HorizontalAlignment="Left" VerticalAlignment="Center" Margin="605,0,0,0" Width="170" Grid.Row="12"/>
                    <Button Content="Replace w/ Data from Grid" Name="PasteAsNewSCGrid" Visibility="visible" HorizontalAlignment="Left" VerticalAlignment="Center" Margin="605,0,0,0" Width="170" Grid.Row="13"/>

                    <Button Content="Create!" Name="CreateNewSCButton" IsEnabled="True" Visibility="visible" HorizontalAlignment="Left" VerticalAlignment="Center" Margin="300,0,0,0" Width="100" Grid.Row="14"/>
                    <CheckBox Name="RegisterNewSCCB" IsEnabled="True" IsChecked="True" HorizontalAlignment="Left" VerticalAlignment="Center" Margin="410,0,0,0" Grid.Row="14"></CheckBox>
                    <Label Name="RegisterNewSCLabel" IsEnabled="True" Content="Register session on local machine" HorizontalAlignment="Left" VerticalAlignment="Center" Margin="430,0,0,0" Grid.Row="14"></Label>    
                </Grid>
            </TabItem>
            <TabItem>
                <TabItem.Header>
                    <StackPanel Orientation="Horizontal">
                        <TextBlock Text="SDDL Helper" Margin="2,0,0,0" VerticalAlignment="Center" />
                    </StackPanel>
                </TabItem.Header>
                <Grid>
                    <Grid.RowDefinitions>
                        <RowDefinition Height="40"/>
                        <RowDefinition Height="40"/>
                        <RowDefinition Height="40"/>
                        <RowDefinition Height="40"/>
                        <RowDefinition Height="40"/>
                    </Grid.RowDefinitions>
                    <Label Name="ConfigureAllowedUsersLabel" Content="Specify Allowed Users (default is BUILTIN\Administrators)" HorizontalAlignment="Left" VerticalAlignment="Center" Margin="30,0,0,0" Grid.Row="0"></Label>    
                    <TextBox Text="" Name="ConfigureAllowedUsersTextBox" IsEnabled="True" Grid.Row="0" HorizontalAlignment="Left" VerticalAlignment="Center" Margin="370,0,0,0" Width="280"></TextBox>
                    <CheckBox Name="Configure2FACB" IsChecked="False" IsEnabled="True" HorizontalAlignment="Left" VerticalAlignment="Center" Margin="50,0,0,0" Grid.Row="1"></CheckBox>
                    <Label Name="Configure2FALabel" Content="Enforce Two Factor Authentication (e.g. Smart Card) using the following group(s)" HorizontalAlignment="Left" VerticalAlignment="Center" Margin="70,0,0,0" Grid.Row="1"></Label>    
                    <TextBox Text="" Name="Configure2FATextBox" IsEnabled="False" Grid.Row="1" HorizontalAlignment="Left" VerticalAlignment="Center" Margin="520,0,0,0" Width="290"></TextBox>
                    <Button Content="Display SDDL" Name="DisplaySDDLButton" IsEnabled="True" Visibility="visible" HorizontalAlignment="Left" VerticalAlignment="Center" Margin="300,0,0,0" Width="150" Grid.Row="2"/>
                    <TextBox Text="" Name="SDDLTextBox" IsEnabled="True" Grid.Row="3" HorizontalAlignment="Left" VerticalAlignment="Center" Margin="100,0,0,0" Width="590"></TextBox>
                    <Label Name="SDDLLabel" IsEnabled="False" Content="You can use this SDDL with Register-PSSessionConfiguration, although it's also possible to do this in the user interface." HorizontalAlignment="Left" VerticalAlignment="Center" Margin="100,0,0,0" Grid.Row="4"></Label>    
                 </Grid>
            </TabItem>
        </TabControl>
    </Grid>
</Window>
'@

$Reader = (New-Object System.XML.XMLNodeReader $XAML)
$FORM = [Windows.Markup.XAMLReader]::Load($Reader)

################################################
# Events
################################################

$FORM.FindName('AddRowGrid').Add_Click({
    AddArray -Name "" -Parameter ""
    UpdateScriptOutput
})

$FORM.FindName('DeleteRowGrid').Add_Click({
    write-host -ForegroundColor white "["(date -format "HH:mm:ss")"] Deleting items from grid..."
    $Global:CommandArray = @()
    $Global:CommandArray += $FORM.FindName('CSVGrid').Itemssource | ? IsChecked -eq $False
    $FORM.FindName('CSVGrid').ItemsSource = $Global:CommandArray
    UpdateScriptOutput
})

$FORM.FindName('DeleteAllRows').Add_Click({
    write-host -ForegroundColor white "["(date -format "HH:mm:ss")"] Deleting all items from grid..."
    $Global:CommandArray = @()
    $FORM.FindName('CSVGrid').ItemsSource = $Global:CommandArray
    UpdateScriptOutput
})

$FORM.FindName('AddRowSCGrid').Add_Click({
    $TempArray = @()
    $tmpObject = select-object -inputobject "" IsChecked, UserGroup, RoleCapability
    $tmpObject.Ischecked = $false
    $tmpObject.UserGroup = ""
    $tmpObject.RoleCapability = ""    
    $TempArray += $tmpObject
    If ($FORM.FindName('SCGrid').Items.Count -eq 0)
    {$FORM.FindName('SCGrid').ItemsSource = $TempArray}
    else {$FORM.FindName('SCGrid').ItemsSource += $TempArray}

})

$FORM.FindName('DeleteRowSCGrid').Add_Click({
    write-host -ForegroundColor white "["(date -format "HH:mm:ss")"] Deleting items from grid..."
    $TempArray = @()
    $TempArray += $FORM.FindName('SCGrid').Itemssource | ? IsChecked -eq $False
    $FORM.FindName('SCGrid').ItemsSource = $TempArray
})

$FORM.FindName('DeleteAllRowsSCGrid').Add_Click({
    write-host -ForegroundColor white "["(date -format "HH:mm:ss")"] Deleting all items from grid..."
    $FORM.FindName('SCGrid').ItemsSource = @()
})

$FORM.FindName('RSOPSCGrid').Add_Click({
    write-host -ForegroundColor white "["(date -format "HH:mm:ss")"] Displaying resultant set of cmdlets for selected user..."
    write-host -ForegroundColor gray "["(date -format "HH:mm:ss")"] -- Note this may may fail if you select a group instead of a user, or if one of the specified role capabilities does not exist. The script output will mention it."
    $RSOPUser = (($FORM.FindName('SCGrid').ItemsSource | ? IsChecked -eq $True).UserGroup -join '')
    If ($RSOPUser)
        {
        $RSOPConfiguration = $FORM.FindName('SCListBox').SelectedItem
        write-host -ForegroundColor gray "["(date -format "HH:mm:ss")"] -- User is $RSOPUser and configuration is $RSOPConfiguration"
        $RSOPData = (Get-PSSessionCapability -ConfigurationName ($FORM.FindName('SCListBox').SelectedItem) -Username $RSOPUser)
        write-host $RSOPData -Separator `n
        }
        else
        {
        write-host -ForegroundColor red "["(date -format "HH:mm:ss")"] -- WARNING: No user was selected in the grid before requesting resultant set of cmdlets"
        }
    write-host -ForegroundColor white "["(date -format "HH:mm:ss")"] Displaying resultant set of cmdlets for selected user...Done!"
})

$FORM.FindName('AddRowNewSCGrid').Add_Click({
    $TempArray = @()
    $tmpObject = select-object -inputobject "" IsChecked, UserGroup, RoleCapability
    $tmpObject.Ischecked = $false
    $tmpObject.UserGroup = ""
    $tmpObject.RoleCapability = ""    
    $TempArray += $tmpObject
    If ($FORM.FindName('NewSCGrid').Items.Count -eq 0)
    {$FORM.FindName('NewSCGrid').ItemsSource = $TempArray}
    else {$FORM.FindName('NewSCGrid').ItemsSource += $TempArray}
})

$FORM.FindName('DeleteRowNewSCGrid').Add_Click({
    write-host -ForegroundColor white "["(date -format "HH:mm:ss")"] Deleting items from grid..."
    $TempArray = @()
    $TempArray += $FORM.FindName('NewSCGrid').Itemssource | ? IsChecked -eq $False
    $FORM.FindName('NewSCGrid').ItemsSource = $TempArray
})

$FORM.FindName('DeleteAllRowsNewSCGrid').Add_Click({
    write-host -ForegroundColor white "["(date -format "HH:mm:ss")"] Deleting all items from grid..."
    $FORM.FindName('NewSCGrid').ItemsSource = @()
})

$FORM.FindName('AddModuleFullToGridButton').Add_Click({
    If ($FORM.FindName('FilterModuleComboBox').Text -eq "")
        {
        popup -Message "Please select a module"
        }
        else
        {    
        If (($FORM.FindName('CSVGrid').ItemsSource | ? Module -eq $FORM.FindName('FilterModuleComboBox').Text | ? Name -eq "").Parameter.Count -eq 0)
            {
            write-host -ForegroundColor white "["(date -format "HH:mm:ss")"] Adding items to grid..."
            AddArray -Module $FORM.FindName('FilterModuleComboBox').Text -Name "*" -Parameter "" -ValidateSet ""
            UpdateScriptOutput
            }
            else
            {
            write-host -ForegroundColor white "["(date -format "HH:mm:ss")"] Module is already in the grid, we're not adding it again..."
            }
        }
})

$FORM.FindName('AddModuleGetToGridButton').Add_Click({
    If ($FORM.FindName('FilterModuleComboBox').Text -eq "")
        {
        popup -Message "Please select a module"
        }
        else
        {    
        If (($FORM.FindName('CSVGrid').ItemsSource | ? Module -eq $FORM.FindName('FilterModuleComboBox').Text | ? Name -eq "Get-*").Parameter.Count -eq 0)
            {
            write-host -ForegroundColor white "["(date -format "HH:mm:ss")"] Adding items to grid..."
            AddArray -Module $FORM.FindName('FilterModuleComboBox').Text -Name "Get-*" -Parameter "" -ValidateSet ""
            UpdateScriptOutput
            }
            else
            {
            write-host -ForegroundColor white "["(date -format "HH:mm:ss")"] Module is already in the grid with Get-* cmdlets, we're not adding it again..."
            }
        }
})

$FORM.FindName('AddToGrid').Add_Click({
    write-host -ForegroundColor white "["(date -format "HH:mm:ss")"] Adding items to grid..."
    $PropertiesDiscarded = 0
    $PropertiesAdded = 0
    $PropertiesChecked = $false
    Foreach ($Property in $FORM.FindName('PickPropertiesComboBox').Items)
        {
        If ($Property.PropertyChecked -eq $true)
            {
            $PropertiesChecked = $true
            If (($FORM.FindName('CSVGrid').ItemsSource | ? Name -eq $FORM.FindName('PickCmdletComboBox').Text | ? Parameter -eq $Property.PropertyName).Parameter.Count -eq 0)
                {
                $command = (get-command $FORM.FindName('PickCmdletComboBox').Text)
                $potentialvalues=@()
                
                try {
                    If (($command.ResolveParameter($Property.PropertyName).ParameterType.Name) -eq "String")
                    {
                    $p=$command.Parametersets[0].parameters |?{$_.name -eq $Property.PropertyName}
                    $potentialvalues = ($p.Attributes).ValidValues
                    # Thanks http://blogs.msdn.com/b/powershell/archive/2006/05/10/594175.aspx?Redirected=true
                    }
                    else
                    {
                    $potentialvalues = [Enum]::GetNames($command.ResolveParameter($Property.PropertyName).ParameterType.FullName)
                    }
                    }
                catch {}
                $ValidateSetValue = "'" + ($potentialvalues -join "','") + "'"
                If ($ValidateSetValue -eq "''") {$ValidateSetValue = ""}
                AddArray -Module "" -Name $FORM.FindName('PickCmdletComboBox').Text -Parameter $Property.PropertyName -ValidateSet $ValidateSetValue
                $PropertiesAdded = $PropertiesAdded +1
                }
                else
                {$PropertiesDiscarded = $PropertiesDiscarded +1}
            }
        }
    If ($PropertiesAdded -eq 0)
        {
        If (($FORM.FindName('CSVGrid').ItemsSource | ? Name -eq $FORM.FindName('PickCmdletComboBox').Text).Parameter.Count -eq 0)
            {
            AddArray -Name $FORM.FindName('PickCmdletComboBox').Text -Parameter ""
            }
            else
            {write-host -ForegroundColor white "["(date -format "HH:mm:ss")"] NOTE : The cmdlet was not added, because it was already found in the grid."}
        }
    If ($PropertiesDiscarded -gt 0) {write-host -ForegroundColor white "["(date -format "HH:mm:ss")"] NOTE : $PropertiesDiscarded propertie(s) were not added, because they were already found in the grid."}
    #write-host -ForegroundColor white "["(date -format "HH:mm:ss")"] Adding items to grid...done!"
    UpdateScriptOutput
})

$FORM.FindName('AddRunbookToGrid').Add_Click({
    write-host -ForegroundColor white "["(date -format "HH:mm:ss")"] Adding Runbooks to grid..."
    $RunbooksToAdd = ""
    Foreach ($Property in $FORM.FindName('PickRunbooksComboBox').Items)
        {
        If ($Property.RunbookChecked -eq $true)
            {
            If (($FORM.FindName('CSVGrid').ItemsSource | ? Name -eq $FORM.FindName('PickRunbooksComboBox').Text | ? Parameter -eq $Property.PropertyName).Parameter.Count -eq 0)
                {
                $RunbooksToAdd += ",'" + $Property.RunbookName + "'"
                }
            }
        }
    $RunbooksToAdd = $RunbooksToAdd.Substring(1,$RunbooksToAdd.Length-1)
    #We check if there are already some entries for the SMA cmdlets and, if yes, we add to them
    If (($FORM.FindName('CSVGrid').ItemsSource | ? Name -eq "Start-SmaRunbook" | ? Parameter -eq "Name").Parameter.Count -ne 0)
            {
            $RunbookToAdd = (($RunbooksToAdd + "," + ($FORM.FindName('CSVGrid').ItemsSource | ? Name -eq "Start-SmaRunbook" | ? Parameter -eq "Name").ValidateSet).Split(",") | select-object -unique) -join ","
            $Global:CommandArray = @()
            $Global:CommandArray += $FORM.FindName('CSVGrid').Itemssource | ? Name -ne "Start-SmaRunbook"
            $FORM.FindName('CSVGrid').ItemsSource = $Global:CommandArray
            }
    AddArray -Module "" -Name "Start-SmaRunbook" -Parameter "Name" -ValidateSet $RunbooksToAdd
    AddArray -Module "" -Name "Start-SmaRunbook" -Parameter "Parameters" -ValidateSet ""
    AddArray -Module "" -Name "Start-SmaRunbook" -Parameter "WebServiceEndpoint" -ValidateSet ("'" + $Global:SMAWS + "'")
    AddArray -Module "" -Name "Start-SmaRunbook" -Parameter "Port" -ValidateSet ("'" + $Global:SMAPort + "'")
    #AddArray -Module "" -Name "Stop-SmaRunbook" -Parameter "Name" -ValidateSet $RunbooksToAdd
    UpdateScriptOutput
})

$FORM.FindName('PickCmdletComboBox').Add_DropDownClosed({
    If ($FORM.FindName('PickCmdletComboBox').Text)
    {
        $SelectedCmdletParameters = (Get-Command $FORM.FindName('PickCmdletComboBox').Text | % parameters).keys
        $Global:PropertyArray = @()
        Foreach ($SelectedCmdletParameter in $SelectedCmdletParameters)
            {
            $tmpObject2 = select-object -inputobject "" PropertyChecked, PropertyName
            $tmpObject2.PropertyChecked = $false
            $tmpObject2.PropertyName = $SelectedCmdletParameter
            $Global:PropertyArray += $tmpObject2   
            $FORM.FindName('PickPropertiesComboBox').ItemsSource = $Global:PropertyArray
            $FORM.FindName('PickPropertiesComboBox').IsDropDownOpen = $true
            }
    }
})

$FORM.FindName('CreateRoleCapabilityButton').Add_Click({
    write-host -ForegroundColor white "["(date -format "HH:mm:ss")"] Creating PSRC file..."

    $AskDiscardChangesAnswer = 6
    If ($Global:OriginalPSRCData -ne $FORM.FindName('PSRCTextBlock').Text)
         {
         write-host -ForegroundColor gray "["(date -format "HH:mm:ss")"] -- Prompting for unsaved changes"
         $AskDiscardChanges = new-object -comobject wscript.shell
         $AskDiscardChangesAnswer = $AskDiscardChanges.popup("There seems to be some unsaved changes in the Role Capability output window. Are you sure you want to proceed? unsaved changes will be lost)",0,"Unsaved changes",4)
         }
    If ($AskDiscardChangesAnswer -eq 6)
                    {
                    $MaintenanceRoleCapabilityCreationParams = @{
                    Author =
                        $FORM.FindName('NewRoleCapabilityAuthorTextBox').Text
                    CompanyName=
                        $FORM.FindName('NewRoleCapabilityCompanyTextBox').Text
                        }
                    $PSRCModuleName = $FORM.FindName('NewRoleCapabilityModuleTextBox').Text
                    $PSRCName = $FORM.FindName('NewRoleCapabilityNameTextBox').Text

                    # Create the demo module, which will contain the demo Role Capability File
                    If ((Test-Path "$env:ProgramFiles\WindowsPowerShell\Modules\$PSRCModuleName") -eq $False)
                        {
                        write-host -ForegroundColor gray "["(date -format "HH:mm:ss")"] -- Creating module directory..."
                        New-Item -Path “$env:ProgramFiles\WindowsPowerShell\Modules\$PSRCModuleName” -ItemType Directory
                        New-ModuleManifest -Path “$env:ProgramFiles\WindowsPowerShell\Modules\$PSRCModuleName\$PSRCModuleName.psd1"
                        New-Item -Path “$env:ProgramFiles\WindowsPowerShell\Modules\$PSRCModuleName\RoleCapabilities” -ItemType Directory
                        }

                    # Create the Role Capability file
                    write-host -ForegroundColor gray "["(date -format "HH:mm:ss")"] -- Creating role capability file..."
                    New-PSRoleCapabilityFile -Path “$env:ProgramFiles\WindowsPowerShell\Modules\$PSRCModuleName\RoleCapabilities\$PSRCName.psrc" @MaintenanceRoleCapabilityCreationParams
                    $FORM.FindName('PSRCTextBlock').Text = Get-Content -Path “$env:ProgramFiles\WindowsPowerShell\Modules\$PSRCModuleName\RoleCapabilities\$PSRCName.psrc" -Raw
                    $Global:OriginalPSRCData = $FORM.FindName('PSRCTextBlock').Text 
                    $FORM.FindName('PSRCPathLabel').Content = “$env:ProgramFiles\WindowsPowerShell\Modules\$PSRCModuleName\RoleCapabilities\$PSRCName.psrc"
                    ReloadPSRCListBox
                }
                else
                {
                write-host -ForegroundColor gray "["(date -format "HH:mm:ss")"] -- User exited because to prevent losing unsaved changes"
                }                

    write-host -ForegroundColor white "["(date -format "HH:mm:ss")"] Creating PSRC file....Done!"

})

$FORM.FindName('OpenRoleCapabilityButton').Add_Click({
    write-host -ForegroundColor white "["(date -format "HH:mm:ss")"] Opening existing PSRC file..."

    $AskDiscardChangesAnswer = 6
    If ($Global:OriginalPSRCData -ne $FORM.FindName('PSRCTextBlock').Text)
         {
         write-host -ForegroundColor gray "["(date -format "HH:mm:ss")"] -- Prompting for unsaved changes"
         $AskDiscardChanges = new-object -comobject wscript.shell
         $AskDiscardChangesAnswer = $AskDiscardChanges.popup("There seems to be some unsaved changes in the Role Capability output window. Are you sure you want to proceed? unsaved changes will be lost)",0,"Unsaved changes",4)
         }
    If ($AskDiscardChangesAnswer -eq 6)
                {
                [void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")
                $OpenFileWindow = New-Object System.Windows.Forms.OpenFileDialog
                $OpenFileWindow.InitialDirectory = "C:\Program Files\WindowsPowerShell\Modules"
                $OpenFileWindow.ShowHelp=$false
                $OpenFileWindow.Filter = "psrc files (*.psrc)|*.psrc";
                if($OpenFileWindow.ShowDialog() -eq "OK")
                    {
                    $PSRCFileLocation = $OpenFileWindow.FileName.substring(0, $OpenFileWindow.FileName.LastIndexOf("\"))
                    $PSRCModuleName = $OpenFileWindow.FileName.split("\")[$OpenFileWindow.FileName.split("\").Count-3]
                    $PSRCFileName = ($OpenFileWindow.FileName.split("\")[$OpenFileWindow.FileName.split("\").Count-1]).split(".")[0]
                    write-host -ForegroundColor gray "["(date -format "HH:mm:ss")"] -- Importing PSRC File '$PSRCFileName' in module '$PSRCModuleName'..."
                    $FORM.FindName('PSRCPathLabel').Content = $OpenFileWindow.FileName
                    $FORM.FindName('PSRCTextBlock').Text = Get-Content -Path $OpenFileWindow.FileName -Raw
                    $Global:OriginalPSRCData = $FORM.FindName('PSRCTextBlock').Text 
                    write-host -ForegroundColor white "["(date -format "HH:mm:ss")"] Opening existing PSRC file....Done!"
                    }
                    else
                    {
                    write-host -ForegroundColor white "["(date -format "HH:mm:ss")"] No PSRC file was specified by user, returning to main window..."
                    }
                }
                else
                {
                write-host -ForegroundColor gray "["(date -format "HH:mm:ss")"] -- User exited because to prevent losing unsaved changes"
                write-host -ForegroundColor white "["(date -format "HH:mm:ss")"] Opening existing PSRC file....Done!"
                }


})

$FORM.FindName('SaveRoleCapabilityButton').Add_Click({
    write-host -ForegroundColor white "["(date -format "HH:mm:ss")"] Saving PSRC file..."    
    If ($FORM.FindName('PSRCPathLabel').Content -ne "No PSRC file open right now")
        {
        write-host -ForegroundColor gray "["(date -format "HH:mm:ss")"] -- Saving file " $FORM.FindName('PSRCPathLabel').Content
        Set-Content -Path $FORM.FindName('PSRCPathLabel').Content -Value $FORM.FindName('PSRCTextBlock').Text -Force
        $Global:OriginalPSRCData = $FORM.FindName('PSRCTextBlock').Text
        }
        else
        {
        write-host -ForegroundColor gray "["(date -format "HH:mm:ss")"] -- There is no PSRC file open right now, please create or open one using the options in this tab before trying to save changes."
        }
    write-host -ForegroundColor white "["(date -format "HH:mm:ss")"] Saving PSRC file....Done!"

})

$FORM.FindName('ImportAuditLog').Add_Click({
    write-host -ForegroundColor white "["(date -format "HH:mm:ss")"] Importing from PowerShell Operational event log (verbose auditing may need to be enabled)..."
    write-host -ForegroundColor gray "["(date -format "HH:mm:ss")"] Reading events (this may take up a to minute depending on the number of events)..."
    #Commands after Where-Objects are the excluded ones
    $JEAApprovedCommands = @("Get-Command",
                        "Get-Help",
                        "Exit-PSSession",
                        "Out-Default",
                        "Measure-Object",
                        "Select-Object",
                        "Clear-Host",
                        "Get-FormatData",
                        "Get-UserInfo")

    $Events = Get-WinEvent -FilterHashtable @{ LogName = "Microsoft-Windows-PowerShell/Operational" ; ID = 4103} | Where-Object {$_.message -match 'CommandInvocation'} 
    $Parsed_Events = $Events.message | ConvertFrom-String -TemplateFile ((Get-Location -PSProvider FileSystem).Path + "\templatemessage.txt")
    $TempCommands = $Parsed_Events.CommandName | Select-Object -Unique
    $AuditArray = @()
    Foreach ($Command in $TempCommands)
        {
        If ($Command -iin $JEAApprovedCommands) {write-host -ForegroundColor gray "["(date -format "HH:mm:ss")"] Excluding $Command from audit analysis, as it is pre-approved in any JEA toolkit"}
        else
            {
            #$AuditCommands += $Command
            $tmpObject = select-object -inputobject "" IsChecked, Module, Name, Parameter, ValidateSet, ValidatePattern
            $tmpObject.Ischecked = $false
            $tmpObject.Module = ""
            $tmpObject.Name = $Command
            $tmpObject.Parameter = ""
            $tmpObject.ValidateSet = ""
            $tmpObject.ValidatePattern = ""
            $AuditArray += $tmpObject
            }
        }
    write-host -ForegroundColor gray "["(date -format "HH:mm:ss")"] Reading events...done!"
    If ($AuditArray.Count -gt 0)
        {
        write-host -ForegroundColor gray "["(date -format "HH:mm:ss")"] Processing" $AuditArray.Count"cmdlets..."
        If ($FORM.FindName('ImportCSVFileAction').Text -eq  "Replace grid")
            {$FORM.FindName('CSVGrid').ItemsSource = $AuditArray}
            else {$FORM.FindName('CSVGrid').ItemsSource += $AuditArray}
        UpdateScriptOutput
        }
        else
        {
        write-host -ForegroundColor gray "["(date -format "HH:mm:ss")"] No cmdets were found eligible to add."
        }
})

$FORM.FindName('FilterModuleButton').Add_Click({
    write-host -ForegroundColor white "["(date -format "HH:mm:ss")"] Filtering cmdlet list for module" $FORM.FindName('FilterModuleComboBox').Text "..."
    $Global:CmdletList = Get-Command -Module $FORM.FindName('FilterModuleComboBox').Text | Sort-Object Name | Select Name
    UpdateCmdletList
 })

 $FORM.FindName('RemoveFilterModuleButton').Add_Click({
    write-host -ForegroundColor white "["(date -format "HH:mm:ss")"] Removing filter on cmdlet list..."
    $Global:CmdletList = Get-Command | Sort-Object Name | Select Name
    UpdateCmdletList
 })

  $FORM.FindName('ImportModuleButton').Add_Click({
    write-host -ForegroundColor white "["(date -format "HH:mm:ss")"] Importing module" $FORM.FindName('ImportModuleTextBox').Text "..."
    $eap = $ErrorActionPreference = "SilentlyContinue"
    Import-Module  $FORM.FindName('ImportModuleTextBox').Text
        if (!$?) {
            $ErrorActionPreference =$eap
            write-host -ForegroundColor red "["(date -format "HH:mm:ss")"] WARNING : Module" $FORM.FindName('ImportModuleTextBox').Text "could not be imported. Please check module name and existence."           }
            popup -Message ("WARNING : Module " + $FORM.FindName('ImportModuleTextBox').Text + " could not be imported. Please check module name and existence.")
            else{  
            $ErrorActionPreference =$eap
            $Global:CmdletList = Get-Command | Sort-Object Name | Select Name
            UpdateCmdletList
            UpdateModuleList
            write-host -ForegroundColor white "["(date -format "HH:mm:ss")"] Importing module" $FORM.FindName('ImportModuleTextBox').Text "...Done!"
            popup -Message ("Module " + $FORM.FindName('ImportModuleTextBox').Text + " was imported.")
            }
 })

$FORM.FindName('CopyToClipboard').Add_Click({
    $null = [Reflection.Assembly]::LoadWithPartialName(“System.Windows.Forms”)
    $dataObject = New-Object windows.forms.dataobject
    $dataObject.SetData([Windows.Forms.DataFormats]::UnicodeText, $true, $FORM.FindName('PSRCTextBlock').Text)
    [Windows.Forms.Clipboard]::SetDataObject($dataObject, $true)
    write-host -ForegroundColor white "["(date -format "HH:mm:ss")"] Copied script content to clipboard."
    popup -Message "Script content was copied to clipboard."
})

$FORM.FindName('CopyToClipboard2').Add_Click({
    $null = [Reflection.Assembly]::LoadWithPartialName(“System.Windows.Forms”)
    $dataObject = New-Object windows.forms.dataobject
    $dataObject.SetData([Windows.Forms.DataFormats]::UnicodeText, $true, $FORM.FindName('ScriptOutputTextBlock').Text)
    [Windows.Forms.Clipboard]::SetDataObject($dataObject, $true)
    write-host -ForegroundColor white "["(date -format "HH:mm:ss")"] Copied script content to clipboard."
    popup -Message "Script content was copied to clipboard."
})

$FORM.FindName('OpenExistingPSRCFile').Add_Click({

    write-host -ForegroundColor white "["(date -format "HH:mm:ss")"] Gathering grid input from existing PSRC file..."
    write-host -ForegroundColor gray "["(date -format "HH:mm:ss")"] -- Querying for PSRC file to open..."
    [void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")
    $OpenFileWindow = New-Object System.Windows.Forms.OpenFileDialog
    $OpenFileWindow.InitialDirectory = "C:\Program Files\WindowsPowerShell\Modules"
    $OpenFileWindow.ShowHelp=$false
    $OpenFileWindow.Filter = "psrc files (*.psrc)|*.psrc";
    if($OpenFileWindow.ShowDialog() -eq "OK")
        {
        $PSRCFileLocation = $OpenFileWindow.FileName.substring(0, $OpenFileWindow.FileName.LastIndexOf("\"))
        $PSRCModuleName = $OpenFileWindow.FileName.split("\")[$OpenFileWindow.FileName.split("\").Count-3]
        $PSRCFileName = ($OpenFileWindow.FileName.split("\")[$OpenFileWindow.FileName.split("\").Count-1]).split(".")[0]
        write-host -ForegroundColor gray "["(date -format "HH:mm:ss")"] -- Importing PSRC File '$PSRCFileName' in module '$PSRCModuleName'..."
        $PSRCData = Import-PowerShellDataFile -Path ($OpenFileWindow.FileName)
        $SCArray = @()
        Foreach ($CmdletData in $PSRCData.VisibleCmdlets)
            {
            If ($CmdletData.Count -eq 1)
                {
                If ($CmdletData.Contains("\"))
                    #module is mentioned
                    {
                    $tmpObject = select-object -inputobject "" IsChecked, Module, Name, Parameter, ValidateSet, ValidatePattern
                    $tmpObject.Ischecked = $False
                    $tmpObject.Module = $CmdletData.Split("\")[0]
                    $tmpObject.Name = $CmdletData.Split("\")[1]
                    $tmpObject.Parameter = ""
                    $tmpObject.ValidateSet = ""
                    $tmpObject.ValidatePattern = ""
                    $SCArray += $tmpObject
                    }
                    else
                    #name row only
                    {
                    $tmpObject = select-object -inputobject "" IsChecked, Module, Name, Parameter, ValidateSet, ValidatePattern
                    $tmpObject.Ischecked = $False
                    $tmpObject.Module = ""
                    $tmpObject.Name = $CmdletData
                    $tmpObject.Parameter = ""
                    $tmpObject.ValidateSet = ""
                    $tmpObject.ValidatePattern = ""
                    $SCArray += $tmpObject
                    }
                }
            If ($CmdletData.Count -eq 2)
                #parameters are included
                {
                $CmdletParam = $Cmdletdata.Get_Item("parameters")
                Switch ($CmdletParam.GetType())
                    {
                    default
                            {
                            $tmpObject = select-object -inputobject "" IsChecked, Module, Name, Parameter, ValidateSet, ValidatePattern
                            $tmpObject.Ischecked = $False
                            $tmpObject.Module = ""
                            $tmpObject.Name = $CmdletData["name"]
                            $tmpObject.Parameter = $CmdletParam.Get_Item("name")
                            If ($CmdletParam.Get_Item("ValidateSet")) {$tmpObject.ValidateSet=("'" + ($CmdletParam.Get_Item("ValidateSet") -join "','") + "'")} else {$tmpObject.ValidateSet=""}
                            If ($CmdletParam.Get_Item("ValidatePattern")) {$tmpObject.ValidatePattern = ("'" + $CmdletParam.Get_Item("ValidatePattern") + "'")} else {$tmpObject.ValidatePattern=""}
                            $SCArray += $tmpObject
                            }
                    "System.Object[]"
                            {
                            foreach ($Param in $CmdletParam)
                                {
                                $tmpObject = select-object -inputobject "" IsChecked, Module, Name, Parameter, ValidateSet, ValidatePattern
                                $tmpObject.Ischecked = $False
                                $tmpObject.Module = ""
                                $tmpObject.Name = $CmdletData["name"]
                                $tmpObject.Parameter = $Param.Get_Item("name")
                                If ($Param.Get_Item("ValidateSet")) {$tmpObject.ValidateSet=("'" + ($Param.Get_Item("ValidateSet") -join "','") + "'")} else {$tmpObject.ValidateSet=""}
                                If ($Param.Get_Item("ValidatePattern")) {$tmpObject.ValidatePattern=("'" + $Param.Get_Item("ValidatePattern") + "'")} else {$tmpObject.ValidatePattern=""}
                                $SCArray += $tmpObject
                                }
                            }
                    }
                }
            }
        write-host -ForegroundColor gray "["(date -format "HH:mm:ss")"] -- Updating grid data..."
        If ($FORM.FindName('ImportCSVFileAction').Text -eq  "Replace grid")
            {$FORM.FindName('CSVGrid').ItemsSource = $SCArray}
            else {$FORM.FindName('CSVGrid').ItemsSource += $SCArray}
        UpdateScriptOutput
        write-host -ForegroundColor white "["(date -format "HH:mm:ss")"] Gathering grid input from existing PSRC file...done!"
        }
        else
        {
        write-host -ForegroundColor white "["(date -format "HH:mm:ss")"] No PSRC file was specified by user, returning to main window..."
        }

})

$FORM.FindName('Configure2FACB').Add_Checked({
    $FORM.FindName('Configure2FATextBox').IsEnabled=$True
})

$FORM.FindName('Configure2FACB').Add_UnChecked({
    $FORM.FindName('Configure2FATextBox').IsEnabled=$False
})



$FORM.FindName('DisplaySDDLButton').Add_Click({
    write-host -ForegroundColor white "["(date -format "HH:mm:ss")"] Validating account list to generate SDDL string..."
    $FORM.FindName('SDDLTextBox').Text= "Computing SDDL..."
    #Working with 2FA data, if requested and filled in the user interface
    $Global:SDDL2FAAccountList = @()
    If (($FORM.FindName('Configure2FACB').IsChecked -eq $True) -and ($FORM.FindName('Configure2FATextBox').Text -ne ""))
        {
        $2FAAccounts = $FORM.FindName('Configure2FATextBox').Text.Split(";")
        }
        else
        {
        $2FAAccounts = $null
        }

    $ErrorAccounts = 0

    $SDDL2FAMemberOfList = @()
    foreach ($Account in $2FAAccounts)
        {
        $objUser = New-Object System.Security.Principal.NTAccount($Account)
        $eap = $ErrorActionPreference = "SilentlyContinue"
        $strSID = $objUser.Translate([System.Security.Principal.SecurityIdentifier])
        if (!$?) {
            $ErrorActionPreference =$eap
            write-host -ForegroundColor red "["(date -format "HH:mm:ss")"] WARNING : SID could not be resolved for account $Account. This 2FA account has not been added to the resulting SDDL output."
            $ErrorAccounts += 1
            }
            else
            {
            $SDDL2FAMemberOfList += "(Member_of {SID(" + $strSID + ")})"
            $Global:SDDL2FAAccountList +=$Account
            }
        }

    switch ($SDDL2FAMemberOfList.count)
        {
            0
            {
            $strSDDL2FA = ""
            }
            1
            {
            $strSDDL2FA = ";" + $SDDL2FAMemberOfList
            }
            default
            {
            $strSDDL2FA = ";("
            foreach ($SDDL2FAMemberOf in $SDDL2FAMemberOfList)
                {
                    $strSDDL2FA = $strSDDL2FA + $SDDL2FAMemberOf +" && "
                  }
            $strSDDL2FA = $strSDDL2FA.Substring(0,$strSDDL2FA.Length -4) + ")"
            }
        }
   If ($ErrorAccounts -eq $2FAAccounts.Count)
        {
        $strSDDL2FA = ""
        If (($FORM.FindName('Configure2FACB').IsChecked -eq $True) -and ($FORM.FindName('Configure2FATextBox').Text -ne ""))
            {write-host -ForegroundColor red "["(date -format "HH:mm:ss")"] WARNING : None of the user(s) or group(s) provided for two-factor authentication could be resolved, so 2FA data has not be included in the resulting SDDL output."}
        }

    #Working with delegation data, if requested and filled in the user interface
    $Global:SDDLAccountList = @()
    If ($FORM.FindName('ConfigureAllowedUsersTextBox').Text -ne "")
        {$Accounts = $FORM.FindName('ConfigureAllowedUsersTextBox').Text.Split(";")}
        else
        {$Accounts = $null}
    $Global:strSDDL = "O:NSG:BAD:P"
    $ErrorAccounts = 0
    foreach ($Account in $Accounts)
        {
        $objUser = New-Object System.Security.Principal.NTAccount($Account)
        $eap = $ErrorActionPreference = "SilentlyContinue"
        $strSID = $objUser.Translate([System.Security.Principal.SecurityIdentifier])
        if (!$?) {
            $ErrorActionPreference =$eap
            write-host -ForegroundColor red "["(date -format "HH:mm:ss")"] WARNING : SID could not be resolved for account $Account. This account has not been added to the resulting SDDL output."
            $ErrorAccounts += 1
            }
            else
            {
            $Global:strSDDL = $Global:strSDDL + "(A;;GA;;;" + $strSID + $strSDDL2FA + ")"
            $Global:SDDLAccountList +=$Account
            }
        }
   $Global:strSDDL = $Global:strSDDL + "S:P(AU;FA;GA;;;WD)(AU;SA;GXGW;;;WD)"
   If ($ErrorAccounts -eq $Accounts.Count)
        {
        $Global:strSDDL = $Global:DefaultSDDL
        If ($FORM.FindName('ConfigureAllowedUsersTextBox').Text -ne "")
            {write-host -ForegroundColor red "["(date -format "HH:mm:ss")"] WARNING : None of the user(s) or group(s) provided could be resolved, so the resulting SDDL output is the default one associated with the default security (BUILTIN\Administrators)."}
        }
   $FORM.FindName('SDDLTextBox').Text= $Global:strSDDL
   write-host -ForegroundColor white "["(date -format "HH:mm:ss")"] Validating account list to generate SDDL output...done!"
})

$FORM.FindName('TestToolkit').Add_Click({
   
   write-host -ForegroundColor white "["(date -format "HH:mm:ss")"] Testing JEA Session Configuration..."
   $SessionName = $FORM.FindName('SCListBox').SelectedItem
   If ((Get-PSSessionConfiguration -Name $SessionName -ErrorAction SilentlyContinue) -ne $null)
        {
        write-host -ForegroundColor gray "["(date -format "HH:mm:ss")"] JEA Session Configuration was found as both present and active on this local machine, we can proceed with the test."
        $NonAdminCred = Get-Credential  -Message "Please confirm the account and password you would like to use to connect to this JEA session"
        write-host -ForegroundColor gray "["(date -format "HH:mm:ss")"] Connecting to JEA session (with specified user)...This may take a few seconds...PowerShell will return an access denied error if the specificed account does not have the right to connect to this session."
        write-host (Invoke-Expression ("`$s = New-PSSession -ComputerName . -ConfigurationName `$SessionName -Credential `$NonAdminCred"))
        write-host -ForegroundColor gray "["(date -format "HH:mm:ss")"] Displaying available cmdlets..."
        write-host (Invoke-Expression ("Invoke-command `$s {get-command} | out-string"))
        write-host -ForegroundColor gray "["(date -format "HH:mm:ss")"] Exiting JEA session..."
        write-host (Invoke-Expression ("Remove-PSSession `$s"))
        }
        else
        {
        write-host -ForegroundColor red "["(date -format "HH:mm:ss")"] WARNING : This configuration was not found as both present and active on this local machine."
        }
    write-host -ForegroundColor white "["(date -format "HH:mm:ss")"] Testing JEA Session Configuration...done!"
})

$FORM.FindName('ReloadSCListBox').Add_Click({
    ReloadPSSCListBox  
})

$FORM.FindName('OpenExistingPSSCFile').Add_Click({

    write-host -ForegroundColor white "["(date -format "HH:mm:ss")"] Gathering grid input from existing PSSC file..."
    write-host -ForegroundColor gray "["(date -format "HH:mm:ss")"] -- Querying for PSSC file to open..."
    [void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")
    $OpenFileWindow = New-Object System.Windows.Forms.OpenFileDialog
    $OpenFileWindow.InitialDirectory = $FORM.FindName('PSSCFilesLocationTextBox').Text
    $OpenFileWindow.ShowHelp=$false
    $OpenFileWindow.Filter = "pssc files (*.pssc)|*.pssc";
    if($OpenFileWindow.ShowDialog() -eq "OK")
        {
        $PSSCFileLocation = $OpenFileWindow.FileName.substring(0, $OpenFileWindow.FileName.LastIndexOf("\"))
        $PSSCFileName = ($OpenFileWindow.FileName.split("\")[$OpenFileWindow.FileName.split("\").Count-1]).split(".")[0]
        write-host -ForegroundColor gray "["(date -format "HH:mm:ss")"] -- Importing PSSC File '$PSSCFileName' in location '$PSSCFileLocation'..."
        $PSSCData = Import-PowerShellDataFile -Path ($OpenFileWindow.FileName)
        $SCArray = @()
        Foreach ($PSSCRoleDefinition in $PSSCData.RoleDefinitions)
            {
            foreach ($Key in $PSSCRoleDefinition.Keys)
               {
                $AllRCValues = $PSSCRoleDefinition[$Key].Values.Split(" ")
                $tmpObject = select-object -inputobject "" IsChecked, UserGroup, RoleCapability
                $tmpObject.Ischecked = $False
                $tmpObject.UserGroup = $Key
                $ValOutput = ""
                foreach ($Val in $AllRCValues)
                    {$ValOutput +="," + $Val}
                $ValOutput = $ValOutput.TrimStart(",")
                $tmpObject.RoleCapability = $ValOutput
                $SCArray += $tmpObject
                }
            }
        write-host -ForegroundColor gray "["(date -format "HH:mm:ss")"] -- Updating grid data..."
        $FORM.FindName('NewSCGrid').ItemsSource = $SCArray
        write-host -ForegroundColor white "["(date -format "HH:mm:ss")"] Gathering grid input from existing PSSC file...done!"
        }
        else
        {
        write-host -ForegroundColor white "["(date -format "HH:mm:ss")"] No PSSC file was specified by user, returning to main window..."
        }

})

$FORM.FindName('SCListBox').Add_SelectionChanged({
    $PSSCData = Import-PowerShellDataFile -Path ((Get-PSSessionConfiguration -Name ($FORM.FindName('SCListBox').SelectedItem)).ConfigFilePath)
    $SCArray = @()
    Foreach ($PSSCRoleDefinition in $PSSCData.RoleDefinitions)
        {
        foreach ($Key in $PSSCRoleDefinition.Keys)
            {
            $AllRCValues = $PSSCRoleDefinition[$Key].Values.Split(" ")
            $tmpObject = select-object -inputobject "" IsChecked, UserGroup, RoleCapability
            $tmpObject.Ischecked = $False
            $tmpObject.UserGroup = $Key
            $ValOutput = ""
            foreach ($Val in $AllRCValues)
                {$ValOutput +="," + $Val}
            $ValOutput = $ValOutput.TrimStart(",")
            $tmpObject.RoleCapability = $ValOutput
            $SCArray += $tmpObject
            }
        }
    $FORM.FindName('SCGrid').ItemsSource = $SCArray
})

$FORM.FindName('RCListBox').Add_SelectionChanged({

        If ($FORM.FindName('RCListBox').Items.Count -ne 0)
            {
            write-host -ForegroundColor white "["(date -format "HH:mm:ss")"] Opening existing PSRC file...."
            $AskDiscardChangesAnswer = 6
            If ($Global:OriginalPSRCData -ne $FORM.FindName('PSRCTextBlock').Text)
                {
                write-host -ForegroundColor gray "["(date -format "HH:mm:ss")"] -- Prompting for unsaved changes"
                $AskDiscardChanges = new-object -comobject wscript.shell
                $AskDiscardChangesAnswer = $AskDiscardChanges.popup("There seems to be some unsaved changes in the Role Capability output window. Are you sure you want to proceed? unsaved changes will be lost)",0,"Unsaved changes",4)
                }
            If ($AskDiscardChangesAnswer -eq 6)
                    {
                    $PSRCFileLocation = $FORM.FindName('RCListBox').SelectedItem.substring(0, $FORM.FindName('RCListBox').SelectedItem.LastIndexOf("\"))
                    $PSRCModuleName = $FORM.FindName('RCListBox').SelectedItem.split("\")[$FORM.FindName('RCListBox').SelectedItem.split("\").Count-3]
                    $PSRCFileName = ($FORM.FindName('RCListBox').SelectedItem.split("\")[$FORM.FindName('RCListBox').SelectedItem.split("\").Count-1]).split(".")[0]
                    write-host -ForegroundColor gray "["(date -format "HH:mm:ss")"] -- Importing PSRC File '$PSRCFileName' in module '$PSRCModuleName'..."
                    $FORM.FindName('PSRCPathLabel').Content = $FORM.FindName('RCListBox').SelectedItem
                    $FORM.FindName('PSRCTextBlock').Text = Get-Content -Path $FORM.FindName('RCListBox').SelectedItem -Raw
                    $Global:OriginalPSRCData = $FORM.FindName('PSRCTextBlock').Text
                    }
                    else
                    {
                    write-host -ForegroundColor gray "["(date -format "HH:mm:ss")"] -- User exited because to prevent losing unsaved changes"
                    }
            write-host -ForegroundColor white "["(date -format "HH:mm:ss")"] Opening existing PSRC file....Done!"
            }
})

$FORM.FindName('OpenNewSCLocation').Add_Click({
    $PSSCFileLocation = $FORM.FindName('PSSCFilesLocationTextBox').Text
    Invoke-Expression "explorer '/select,$PSSCFileLocation'"
})

$FORM.FindName('CreateNewSCButton').Add_Click({
 
    $sessionName = $FORM.FindName('NewSCName').Text
    $PSSCFileLocation = $FORM.FindName('PSSCFilesLocationTextBox').Text
    write-host -ForegroundColor white "["(date -format "HH:mm:ss")"] Creating session configuration $sessionName..."

    $RoleDefinitionsOuput = @{}
    foreach ($Row in $FORM.FindName('NewSCGrid').ItemsSource)
        {        
        $RoleCapabilityOutput = @()
        Foreach ($T in $Row.RoleCapability.Split(","))
            {
            $RoleCapabilityOutput += $T.TrimStart(" ")
            }
        $RoleCapabilityOutput = $RoleCapabilityOutput.TrimStart(",")
        $RoleDefinitionsOuput += @{$Row.UserGroup = @{RoleCapabilities=$RoleCapabilityOutput}}
        }

    $JEAConfigParams = @{
        SessionType= "RestrictedRemoteServer" 
        RunAsVirtualAccount = $true
        RoleDefinitions = $RoleDefinitionsOuput
        TranscriptDirectory = "$PSSCFileLocation\Transcripts”
        }
     
    if(-not (Test-Path "$PSSCFileLocation"))
    {
        New-Item -Path "$PSSCFileLocation” -ItemType Directory
    }

    New-PSSessionConfigurationFile -Path "$PSSCFileLocation\$sessionName.pssc" @JEAConfigParams

    If ($FORM.FindName('RegisterNewSCCB').IsChecked)
        {
        write-host -ForegroundColor gray "["(date -format "HH:mm:ss")"] -- Registering session configuration $sessionName..."
        if(Get-PSSessionConfiguration -Name $sessionName -ErrorAction SilentlyContinue)
        {
            Unregister-PSSessionConfiguration -Name $sessionName -ErrorAction Stop
        }
        Register-PSSessionConfiguration -Name $sessionName -Path "$PSSCFileLocation\$sessionName.pssc"
        Restart-Service WinRM 
        ReloadPSSCListBox
        write-host -ForegroundColor gray "["(date -format "HH:mm:ss")"] -- Registering session configuration $sessionName...done!"
        }
    write-host -ForegroundColor white "["(date -format "HH:mm:ss")"] Creating session configuration $sessionName...done!"
})


$FORM.FindName('UnregisterSCButton').Add_Click({

    $SessionName = $FORM.FindName('SCListBox').SelectedItem
    write-host -ForegroundColor white "["(date -format "HH:mm:ss")"] Unregistering session configuration $SessionName..."
    if(Get-PSSessionConfiguration -Name $SessionName -ErrorAction SilentlyContinue)
    {
        Unregister-PSSessionConfiguration -Name $SessionName -ErrorAction Stop
    }
    ReloadPSSCListBox
    write-host -ForegroundColor white "["(date -format "HH:mm:ss")"] Unregistering session configuration $SessionName...done!"

})

$FORM.FindName('SaveEditedSCGrid').Add_Click({
    write-host -ForegroundColor white "["(date -format "HH:mm:ss")"] Updating Existing Configuration..."
    $sessionName = $FORM.FindName('SCListBox').SelectedItem
    $PSSCFileLocation = $FORM.FindName('PSSCFilesLocationTextBox').Text
    write-host -ForegroundColor gray "["(date -format "HH:mm:ss")"] -- Creating output string for RoleDefinitions..."


    $RoleDefinitionsOuput = @{}
    foreach ($Row in $FORM.FindName('SCGrid').ItemsSource)
        {        
        $RoleCapabilityOutput = @()
        Foreach ($T in $Row.RoleCapability.Split(","))
            {
            $RoleCapabilityOutput += $T.TrimStart(" ")
            }
        $RoleCapabilityOutput = $RoleCapabilityOutput.TrimStart(",")
        $RoleDefinitionsOuput += @{$Row.UserGroup = @{RoleCapabilities=$RoleCapabilityOutput}}
        }

    write-host -ForegroundColor gray "["(date -format "HH:mm:ss")"] -- Importing definition for existing session, and creating file for updated version..."
    write-host -ForegroundColor gray "["(date -format "HH:mm:ss")"] -- File is stored in path $PSSCFileLocation\$sessionName.pssc"
    $PSSCData = Import-PowerShellDataFile -Path ((Get-PSSessionConfiguration -Name ($FORM.FindName('SCListBox').SelectedItem)).ConfigFilePath)
    $PSSCData.RoleDefinitions = $RoleDefinitionsOuput
    New-PSSessionConfigurationFile -Path "$PSSCFileLocation\$sessionName.pssc" @PSSCData
    write-host -ForegroundColor gray "["(date -format "HH:mm:ss")"] -- Unregistering old session configuration and registering udpated one..."
    Unregister-PSSessionConfiguration -Name $sessionName -ErrorAction Stop
    Register-PSSessionConfiguration -Name $sessionName -Path "$PSSCFileLocation\$sessionName.pssc"
    write-host -ForegroundColor gray "["(date -format "HH:mm:ss")"] -- Restarting WinRM..."
    Restart-Service WinRM 
    write-host -ForegroundColor gray "["(date -format "HH:mm:ss")"] -- Reloading session configuration list in the user interface.."
    ReloadPSSCListBox
    $FORM.FindName('SCListBox').SelectedItem = $sessionName
    write-host -ForegroundColor white "["(date -format "HH:mm:ss")"] Updating Existing Configuration...done!"
})

$FORM.FindName('PasteAsNewSCGrid').Add_Click({
    $FORM.FindName('NewSCGrid').ItemsSource = $FORM.FindName('SCGrid').ItemsSource
})

$FORM.FindName('RefreshRCList').Add_Click({
    ReloadPSRCListBox
})

$FORM.FindName('RefreshScriptOutput').Add_Click({
    UpdateScriptOutput
})

########################################################################################
#Make sure we run elevated, or relaunch as admin
########################################################################################

$CurrentScriptDirectory = $PSCommandPath.Substring(0,$PSCommandPath.LastIndexOf("\"))
Set-Location $CurrentScriptDirectory

    #Thanks to http://gallery.technet.microsoft.com/scriptcenter/63fd1c0d-da57-4fb4-9645-ea52fc4f1dfb
    $IsAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator") 
        if (-not $IsAdmin)  
        {  
            try 
            {  
                $ScriptToLaunch = (Get-Location -PSProvider FileSystem).Path + "\JEAHelperTool.ps1"
                $arg = "-file `"$($ScriptToLaunch)`"" 
                write-host -ForegroundColor yellow "["(date -format "HH:mm:ss")"] WARNING : This script should run with administrative rights - Relaunching the script in elevated mode in 3 seconds..."
                start-sleep 3
                Start-Process "$psHome\powershell.exe" -Verb Runas -ArgumentList $arg -ErrorAction 'stop'
            } 
            catch 
            { 
                write-host -ForegroundColor red "["(date -format "HH:mm:ss")"] Error : Failed to restart script with administrative rights - please make sure this script is launched elevated."  
                break               
            } 
            exit
        }
        else
        {
        write-host -ForegroundColor gray "["(date -format "HH:mm:ss")"] We are running in elevated mode, we can proceed with launching the tool."
        }


################################################
# Main
################################################



write-host -ForegroundColor green "["(date -format "HH:mm:ss")"] JEA Helper Tool v$ToolVersion"

$Global:SDDLAccountList = @()
$Global:strSDDL = $Global:DefaultSDDL

write-host -ForegroundColor white "["(date -format "HH:mm:ss")"] Checking parameters and prerequisites..."
$Global:SMAIntegration = $false
$Global:SMAWS = $SMAEndPointWS
$Global:SMAPort = $SMAEndPointPort
If ($SMAWS)
    {
    $Global:FullRunbookList = @()

                $Global:FullRunbookList  = Invoke-Command -ScriptBlock { 
                        param ($WS,$Port)
                        get-smarunbook -WebServiceEndpoint $WS -Port $Port | select RunbookName, RunbookID, Tags, Description
                        $runbooks
                       } -ArgumentList $Global:SMAWS, $Global:SMAPort -ComputerName ($Global:SMAWS).split("//")[2]

    If (($Global:FullRunbookList.Count -eq 0) -or ($Global:FullRunbookList -eq $mull) -or ($Global:FullRunbookList -eq ""))
        {
        write-host -ForegroundColor red "["(date -format "HH:mm:ss")"] WARNING : Could not connect to SMA server or no runbooks were found. SMA integration will be disabled this time"
        $Global:SMAIntegration = $false
        }
      else
        {
        $PropertyArray = @()
        Foreach ($Runbook  in $Global:FullRunbookList)
            {
            $tmpObject2 = select-object -inputobject "" RunbookChecked, RunbookName
            $tmpObject2.RunbookChecked = $false
            $tmpObject2.RunbookName = $Runbook.RunbookName
            $PropertyArray += $tmpObject2   
            $FORM.FindName('PickRunbooksComboBox').ItemsSource = $PropertyArray
            }
        write-host -ForegroundColor gray "["(date -format "HH:mm:ss")"]" $Global:FullRunbookList.Count "Runbooks were retrieved for SMA integration."
        $Global:SMAIntegration = $true
        }
    }            
    else
    {
    write-host -ForegroundColor white "["(date -format "HH:mm:ss")"] No SMA server specified. SMA integration will not be available this time."
    $Global:SMAIntegration = $false
    }

If ($Global:SMAIntegration -eq $false)
    {
    $FORM.FindName('PickRunbookLabelContainer').IsEnabled = $false
    $FORM.FindName('PickRunbooksComboBox').IsEnabled = $false
    $FORM.FindName('AddRunbookToGrid').IsEnabled = $false
    }

$Global:PropertyArray = New-Object System.Collections.ArrayList 
$Global:CmdletList = Get-Command | Sort-Object Name | Select Name
UpdateCmdletList
UpdateModuleList

If (-not ($FORM.FindName('FilterModuleComboBox').Items -contains "Microsoft.SystemCenter.ServiceManagementAutomation"))
        {write-host -ForegroundColor red "["(date -format "HH:mm:ss")"] WARNING : SMA module was not found on the local machine. Testing JEA sessions configurations involving SMA cmdlets may fail. Designing sessions configurations should be fine."}

$FORM.FindName('ImportCSVFileAction').Items.Add("Replace grid") | out-null
$FORM.FindName('ImportCSVFileAction').Items.Add("Add to grid") | out-null
$FORM.FindName('ImportCSVFileAction').Text = "Replace grid"

$FORM.FindName('PSSCFilesLocationTextBox').Text = $DefaultPSSCFilesLocation

$Global:OriginalPSRCData = $FORM.FindName('PSRCTextBlock').Text

ReloadPSRCListBox
ReloadPSSCListBox

$Global:CommandArray = New-Object System.Collections.ArrayList 
$Global:CommandArray = @()
write-host -ForegroundColor green "["(date -format "HH:mm:ss")"] Displaying GUI..."
$FORM.ShowDialog() | Out-Null
write-host -ForegroundColor green "["(date -format "HH:mm:ss")"] Exiting GUI..."


########################################################################################
# Version History
# Version 2.0
# - Updated to work with the JEA builds in Windows Server 2016 Technical Preview 4
# - Now works works with Role Capabilities (VisibleCmdlets and VisibleFunctions sections) and Session Configurations
# - SDDL output now moved to its own tab for easier copy/paste
# - Updated list of default cmdlets, in the 'audit log' feature
# - New tab to manage relationships between Roles Capabilities and Session Configurations
# - Kept some of the v1.1 features (audit log import, 2 factor authentication support for SDDL)
# - Slight name change "JEA Helper Tool", to remove references to JEA "toolkits"
# Version 1.1 (not released)
# - Updated to work with WMF 5.0 April 2015 and with xJEA 0.2.16.6 (for example, the 'CleanAll' syntax had changed)
# - Updated how enabling/disabling delegation flows into the output script (disabling was not handled properly prior)
# - Updated CSV export to not include the first "checkbox" column, which would make the CSV fail if used directly in JEA
# - Added support for two factor authentication in the delegation model
# - Added a warning for configuration names longer than 16 characters (current limitation in JEA)
# - Added a feature to read cmdlets from audit/operational log - this feature could be improved with further parsing
# Version 1.0
# - Initial release of the JEA Toolkit Helper
########################################################################################