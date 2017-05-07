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
        Title="StyleEventTriggerSample" Height="100" Width="300">
    <Grid>
        <TextBlock Name="lblStyled" Text="Hello, styled world!" FontSize="18" HorizontalAlignment="Center" VerticalAlignment="Center">
            <TextBlock.Style>
                <Style TargetType="TextBlock">
                    <Style.Triggers>
                        <EventTrigger RoutedEvent="MouseEnter">
                            <EventTrigger.Actions>
                                <BeginStoryboard>
                                    <Storyboard>
                                        <DoubleAnimation Duration="0:0:0.300" Storyboard.TargetProperty="FontSize" To="28" />
                                    </Storyboard>
                                </BeginStoryboard>
                            </EventTrigger.Actions>
                        </EventTrigger>
                        <EventTrigger RoutedEvent="MouseLeave">
                            <EventTrigger.Actions>
                                <BeginStoryboard>
                                    <Storyboard>
                                        <DoubleAnimation Duration="0:0:0.800" Storyboard.TargetProperty="FontSize" To="18" />
                                    </Storyboard>
                                </BeginStoryboard>
                            </EventTrigger.Actions>
                        </EventTrigger>
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