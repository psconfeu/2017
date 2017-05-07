#https://powerintheshell.com/2015/12/05/psgui-binding-examples
#requires -Version 2
<#  
        .NOTES 
        ============================================================================
        Date:       20.04.2017
        Presenter:  David das Neves 
        Version:    1.0
        Project:    PSConfEU - GUI  
        Ref:

        ============================================================================ 
        .DESCRIPTION 
        Presentation data        
#> 

function Convert-XAMLtoWindow
{
    param
    (
        [Parameter(Mandatory = $true)]
        [string]
        $XAML,
         
        [string[]]
        $NamedElements,
         
        [switch]
        $PassThru
    )
     
    Add-Type -AssemblyName PresentationFramework
     
    $reader = [System.XML.XMLReader]::Create([System.IO.StringReader]$XAML)
    $result = [System.Windows.Markup.XAMLReader]::Load($reader)
    foreach($Name in $NamedElements)
    {
        $result | Add-Member -MemberType NoteProperty -Name $Name -Value $result.FindName($Name) -Force
    }
     
    if ($PassThru)
    {
        $result
    }
    else
    {
        $result.ShowDialog()
    }
}
 
$XAML = @'
<Window
   xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
   xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
    
   Name="Fenster"
   SizeToContent="WidthAndHeight"
    ResizeMode="CanResizeWithGrip"
   Title="PowerShell WPF Window"
   Topmost="True">
    <Grid>
        <Grid.ColumnDefinitions>
            <ColumnDefinition Width="Auto"/>
        </Grid.ColumnDefinitions>
        <Grid.RowDefinitions>
            <RowDefinition Height="Auto"/>
        </Grid.RowDefinitions>
        <Button Name="btnStop" Content="Stop" Grid.Column="1" HorizontalAlignment="Right" Margin="10" Grid.Row="1" VerticalAlignment="Bottom" Width="75"/>
        <ListView Grid.Column="1" Grid.Row="0" Name="lvEvents" Margin="15,70,25,15" >
            <ListView.View>
                <GridView>
                    <GridView.Columns>
                        <GridViewColumn>
                            <GridViewColumnHeader Content="Name" Width="Auto" MinWidth="200px"/>
                            <GridViewColumn.CellTemplate>
                                <DataTemplate>
                                    <TextBlock Text="{Binding Path=Name}" TextAlignment="Left" Width="Auto" FontWeight="{Binding Path=Set}" />
                                </DataTemplate>
                            </GridViewColumn.CellTemplate>
                        </GridViewColumn>
                    </GridView.Columns>
                </GridView>
            </ListView.View>
        </ListView>
    </Grid>
</Window>
'@
 
$window = Convert-XAMLtoWindow -XAML $XAML -NamedElements 'Fenster', 'btnStop', 'cbbDienste', 'lvVariables', 'lvEvents' -PassThru
  
$window.btnStop.add_Click(
    {
        [System.Object]$sender = $args[0]
        [System.Windows.RoutedEventArgs]$e = $args[1]   
        $prozesse = Get-Process | Select-Object -First 6
        $window.cbbDienste.ItemsSource = $prozesse
        Stop-Process -Name $window.cbbDienste.SelectedValue.Name
    }
)
 
$prozesse = Get-Process | Select-Object -First 20
  
#Binding with PSCustomObjects
[PSCustomObject]$paramList = @()
Get-Process |
Select-Object -First 20 |
ForEach-Object -Process {
    $paramList += @([PSCustomObject]@{
            Set  = if($_.Name.Length -gt 8) 
            {
                'bold'
            }
            else 
            {
                'normal'
            }
            Name = $_.Name
        }      
    )
} 
  
$window.lvEvents.ItemsSource = $paramList
$window.ShowDialog()