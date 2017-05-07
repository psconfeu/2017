<#	
    .NOTES
    ===========================================================================
    Created on:   	09.04.2017
    Created by:   	David das Neves
    Version:        1.0
    Project:        PSGUI
    Filename:       View_PSConfEU2017.ps1
    ===========================================================================
    .DESCRIPTION
    About 
#> 

#region PreFilling
$View_PSConfEU2017.Add_Loaded(
  {
    # Load data
    $Script:Content = (Invoke-WebRequest -Uri powershell.love -UseBasicParsing).Content.SubString(1) |
    ConvertFrom-Json |
    ForEach-Object -Process {
      $_
    }
    
    foreach ($row in $Content)
    {
      $noteProperties = $row.PSObject.Members| Where-Object -FilterScript {
        $_.MemberType -eq 'NoteProperty'
      }
      if ($row.TracksList -eq 'Coffee')
      {
        $row.Title = '|||||||||||||||||||| Coffee Break ||||||||||||||||||||'
      }
      
      if ($row.TracksList -eq 'Commons')
      {
        $row.Title = '|||||||||||||||||||| ' + $row.Title + ' ||||||||||||||||||||'        
      }
      
      if ($row.Audience -eq '')
      {
        $row.Audience = 'English'
      }
      
      if ($row.TracksList -eq 'Food')
      {
        $row.Title = '|||||||||||||||||||| ' + $row.Title + ' |||||||||||||||||||| '
      }
      
      foreach ($prop in $noteProperties)
      {
        $prop.value = $prop.value -replace '&amp;', '&'
      }
      
      #Adding Date Property
      $row | Add-Member -MemberType NoteProperty -Name Date -Value ($row.StartTime -split ' ')[0]
      
      #Adding Day Property
      switch ($row.Date )
      {
        '2017-05-02' 
        {
          $row | Add-Member -MemberType NoteProperty -Name Day -Value 'Tuesday'
        }
        '2017-05-03' 
        {
          $row | Add-Member -MemberType NoteProperty -Name Day -Value 'Wednesday'
        }
        '2017-05-04' 
        {
          $row | Add-Member -MemberType NoteProperty -Name Day -Value 'Thursday'
        }
        '2017-05-05' 
        {
          $row | Add-Member -MemberType NoteProperty -Name Day -Value 'Friday'
        }        
        default      
        {
          ''
        }
      }
      
      $row.StartTime = ($row.StartTime -split ' ')[1]
      $row.EndTime = ($row.EndTime -split ' ')[1]
    }   

    $View_PSConfEU2017_dgData.ItemsSource = $Content    
    $View_PSConfEU2017_dgData.Items.GroupDescriptions.Add((New-Object -TypeName System.Windows.Data.PropertyGroupDescription -ArgumentList 'Day'))
    $View_PSConfEU2017_dgData.Items.GroupDescriptions.Add((New-Object -TypeName System.Windows.Data.PropertyGroupDescription -ArgumentList 'StartTime')) 
  
  

  }
)
#endregion


$View_PSConfEU2017_tbFilter.Add_TextChanged(
  {
    try
    {
      if ($View_PSConfEU2017_tbFilter.Text -notlike '* *')
      {
        $View_PSConfEU2017_dgData.Dispatcher.Invoke([action]{
            $View_PSConfEU2017_dgData.ItemsSource = $Content | Where-Object -FilterScript {
              $_ -like "*$($View_PSConfEU2017_tbFilter.Text)*".ToLower()
            }
        },'Render')
      }
      else
      {
        #More than one filter inserted - each filter will work separatly
        $filters = $View_PSConfEU2017_tbFilter.Text -split ' '
        switch ($filters.Count)
        {
          2           
          { 
            $View_PSConfEU2017_dgData.Dispatcher.Invoke([action]{
                $View_PSConfEU2017_dgData.ItemsSource = $Content | Where-Object -FilterScript {
                  $_ -like "*$($filters[0])*".ToLower() -and $_ -like "*$($filters[1])*".ToLower()
                }
            },'Render') 
          }
          3            
          {
            $View_PSConfEU2017_dgData.Dispatcher.Invoke([action]{
                $View_PSConfEU2017_dgData.ItemsSource = $Content | Where-Object -FilterScript {
                  $_ -like "*$($filters[0])*".ToLower() -and $_ -like "*$($filters[1])*".ToLower() -and $_ -like "*$($filters[2])*".ToLower()
                }
            },'Render')
          }
          4   
          {
            $View_PSConfEU2017_dgData.Dispatcher.Invoke([action]{
                $View_PSConfEU2017_dgData.ItemsSource = $Content | Where-Object -FilterScript {
                  $_ -like "*$($filters[0])*".ToLower() -and $_ -like "*$($filters[1])*".ToLower() -and $_ -like "*$($filters[2])*".ToLower() -and $_ -like "*$($filters[3])*".ToLower()
                }
            },'Render')
          }
  
        }
      }
    }
    catch
    {
      "Error was $_"
      $line = $_.InvocationInfo.ScriptLineNumber
      "Error was in Line $line"
    }
  }
)

$View_PSConfEU2017_dgData.Add_SelectionChanged(
  {
    $View_PSConfEU2017_lSession.Content = ($View_PSConfEU2017_dgData.SelectedItem.Title).Replace('|', '').Trim()
    $View_PSConfEU2017_tbOutput.Text = $View_PSConfEU2017_dgData.SelectedItem.Description
    $View_PSConfEU2017_lSpeaker.Content = $View_PSConfEU2017_dgData.SelectedItem.SpeakerList 
    $View_PSConfEU2017_lRoom.Content = $View_PSConfEU2017_dgData.SelectedItem.Room 
    $View_PSConfEU2017_lAudience.Content = $View_PSConfEU2017_dgData.SelectedItem.Audience 
    $View_PSConfEU2017_lStart.Content = $View_PSConfEU2017_dgData.SelectedItem.StartTime 
    $View_PSConfEU2017_lEnd.Content = $View_PSConfEU2017_dgData.SelectedItem.EndTime
    $View_PSConfEU2017_lDay.Content = $View_PSConfEU2017_dgData.SelectedItem.Day  
  }
)

$View_PSConfEU2017_bGroupClear.Add_Click(
  {
    $View_PSConfEU2017_dgData.Items.GroupDescriptions.Clear()
  }
)

$View_PSConfEU2017_bGroupDayStart.Add_Click(
  {
    $View_PSConfEU2017_dgData.Items.GroupDescriptions.Clear()
    $View_PSConfEU2017_dgData.Items.GroupDescriptions.Add((New-Object -TypeName System.Windows.Data.PropertyGroupDescription -ArgumentList 'Day'))   
    $View_PSConfEU2017_dgData.Items.GroupDescriptions.Add((New-Object -TypeName System.Windows.Data.PropertyGroupDescription -ArgumentList 'StartTime'))   
  }
)

$View_PSConfEU2017_bGroupSpeaker.Add_Click(
  {
    $View_PSConfEU2017_dgData.Items.GroupDescriptions.Clear()
    $View_PSConfEU2017_dgData.Items.GroupDescriptions.Add((New-Object -TypeName System.Windows.Data.PropertyGroupDescription -ArgumentList 'SpeakerList'))       
  }
)

$View_PSConfEU2017_bGroupDayTrack.Add_Click(
  {
    $View_PSConfEU2017_dgData.Items.GroupDescriptions.Clear()
    $View_PSConfEU2017_dgData.Items.GroupDescriptions.Add((New-Object -TypeName System.Windows.Data.PropertyGroupDescription -ArgumentList 'Day'))       
    $View_PSConfEU2017_dgData.Items.GroupDescriptions.Add((New-Object -TypeName System.Windows.Data.PropertyGroupDescription -ArgumentList 'TracksList'))   
  }
)

$View_PSConfEU2017_bGroupAudienceDayStart.Add_Click(
  {
    $View_PSConfEU2017_dgData.Items.GroupDescriptions.Clear()
    $View_PSConfEU2017_dgData.Items.GroupDescriptions.Add((New-Object -TypeName System.Windows.Data.PropertyGroupDescription -ArgumentList 'Audience')) 
    $View_PSConfEU2017_dgData.Items.GroupDescriptions.Add((New-Object -TypeName System.Windows.Data.PropertyGroupDescription -ArgumentList 'Day'))   
    $View_PSConfEU2017_dgData.Items.GroupDescriptions.Add((New-Object -TypeName System.Windows.Data.PropertyGroupDescription -ArgumentList 'StartTime'))         
  }
)
