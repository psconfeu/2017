<#	
    .NOTES
    ===========================================================================
        Created on:   	09.04.2017
        Created by:   	David das Neves
        Version:        1.0
        Project:        PSGUI
        Filename:       Start_PSConfEU2017.ps1
    ===========================================================================
    .DESCRIPTION
        About 
#> 
#region PreFilling
$Start_PSConfEU2017.Add_Activated(
	{
       $Start_PSConfEU2017.Dispatcher.Invoke([action]{},'Render')
       Start-Sleep -Milliseconds 2000 
       $Start_PSConfEU2017.Close() 
	}
)
#endregion


#region EventHandler

#endregion

