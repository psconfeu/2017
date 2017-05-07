#requires -Version 2
<#  
        .NOTES 
        ============================================================================
        Date:       20.04.2017
        Presenter:  David das Neves 
        Version:    1.0
        Project:    PSConfEU - GUI 
        Ref:        http://www.wpf-tutorial.com/styles/trigger-datatrigger-event-trigger/

        ============================================================================ 
        .DESCRIPTION 
        Presentation data        
#> 



$XAML = @'
<Window 
        xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        Title="StyleTriggersSample" Height="100" Width="300">
    <Grid>
        <TextBlock x:Name="tbHW" Text="Hello, styled world!" FontSize="28" HorizontalAlignment="Center" VerticalAlignment="Center">
            <TextBlock.Style>
                <Style TargetType="TextBlock">
                    <Setter Property="Foreground" Value="Blue"></Setter>
                    <Style.Triggers>
                        <Trigger Property="IsMouseOver" Value="True">
                            <Setter Property="Foreground" Value="Red" />
                            <Setter Property="TextDecorations" Value="Underline" />
                        </Trigger>
                    </Style.Triggers>
                </Style>
            </TextBlock.Style>
        </TextBlock>
    </Grid>
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