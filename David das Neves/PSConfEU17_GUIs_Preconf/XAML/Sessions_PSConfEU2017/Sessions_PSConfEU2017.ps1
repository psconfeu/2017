
Set-Location $PSScriptRoot

# Import local PSGUI
Import-Module -Name .\PSGUI\PSGUI.psd1

# Intro
Open-XAMLDialog -DialogName Start_PSConfEU2017 -DialogPath ('.\Start_PSConfEU2017\')

# Load form
Add-Type -Path '.\View_PSConfEU2017\Resources\Xceed.Wpf.DataGrid.dll'
  
#DPI Awareness
$DPISetting = (Get-ItemProperty -Path 'HKCU:\Control Panel\Desktop\WindowMetrics' -Name AppliedDPI).AppliedDPI

#Override
######
$DPISetting = 168

if ($DPISetting -eq 96)
{
  Open-XAMLDialog -DialogName View_PSConfEU2017 -DialogPath ('.\View_PSConfEU2017\')
} 
else
{
  $Content = Get-Content -Path '.\View_PSConfEU2017_highDPI\View_PSConfEU2017_Template.xaml' 
  switch ($DPISetting)
  {
    96 
    {
      $ActualDPI = 100
      $Content = $Content.Replace('#ImageWidth#','450')
      $Content = $Content.Replace('#FontSize#','17')
      $Content = $Content.Replace('#MinWindowHeight#','800')      
    }
    120 
    {
      $ActualDPI = 125
      $Content = $Content.Replace('#ImageWidth#','450')
      $Content = $Content.Replace('#FontSize#','16')
      $Content = $Content.Replace('#MinWindowHeight#','750')      
    }
    144 
    {
      $ActualDPI = 150
      $Content = $Content.Replace('#ImageWidth#','450')
      $Content = $Content.Replace('#FontSize#','15')
      $Content = $Content.Replace('#MinWindowHeight#','750')      
    }
    168 
    {
      $ActualDPI = 175
      $Content = $Content.Replace('#ImageWidth#','450')
      $Content = $Content.Replace('#FontSize#','13')
      $Content = $Content.Replace('#MinWindowHeight#','750')      
    }
    192 
    {
      $ActualDPI = 200
      $Content = $Content.Replace('#ImageWidth#','400')
      $Content = $Content.Replace('#FontSize#','12')
      $Content = $Content.Replace('#MinWindowHeight#','700')      
    }
    {
      $_ -gt 200
    } 
    {
      $ActualDPI = 225
      $Content = $Content.Replace('#ImageWidth#','375')
      $Content = $Content.Replace('#FontSize#','11')
      $Content = $Content.Replace('#MinWindowHeight#','650')      
    }
  }
  $Content | Set-Content '.\View_PSConfEU2017_highDPI\View_PSConfEU2017.xaml' 
  Open-XAMLDialog -DialogName View_PSConfEU2017 -DialogPath ('.\View_PSConfEU2017_highDPI\')
}
