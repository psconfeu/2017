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
# XAML Code from
# http://www.wpf-tutorial.com/styles/trigger-datatrigger-event-trigger/

$XAML = @'
<Window
        xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        Title="StyleDataTriggerSample" Height="200" Width="200">
    <StackPanel HorizontalAlignment="Center" VerticalAlignment="Center">
        <CheckBox Name="cbSample" Content="Hello, world?" />
        <TextBlock HorizontalAlignment="Center" Margin="0,20,0,0" FontSize="48">
            <TextBlock.Style>
                <Style TargetType="TextBlock">
                    <Setter Property="Text" Value="No" />
                    <Setter Property="Foreground" Value="Red" />
                    <Style.Triggers>
                        <DataTrigger Binding="{Binding ElementName=cbSample, Path=IsChecked}" Value="True">
                            <Setter Property="Text" Value="Yes!" />
                            <Setter Property="Foreground" Value="Green" />
                        </DataTrigger>
                    </Style.Triggers>
                </Style>
            </TextBlock.Style>
        </TextBlock>
    </StackPanel>
</Window>
'@

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


$window = Convert-XAMLtoWindow -XAML $XAML -PassThru

$window.ShowDialog()