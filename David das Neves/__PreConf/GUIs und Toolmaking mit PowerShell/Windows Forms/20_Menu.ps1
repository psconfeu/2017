$Question = $host.ui.PromptForChoice(
    "Window Title", "Question?",(
        [System.Management.Automation.Host.ChoiceDescription[]](
            (New-Object System.Management.Automation.Host.ChoiceDescription "&Answer1","Answer1"),
            (New-Object System.Management.Automation.Host.ChoiceDescription "&Answer2","Answer2")
        )
    ), 0
) 
switch($Question){
    0 {Write-Host "Answer1"}
    1 {Write-Host "Answer2"}
}