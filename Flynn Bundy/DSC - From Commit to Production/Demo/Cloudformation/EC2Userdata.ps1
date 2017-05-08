$Timestamp = Get-date -f yyyy_MM_dd-hh-mm-ss
Start-Transcript -Path C:\Userdata_$Timestamp.txt

#Move required modules into PSModulePath
Move-Item C:\windows\temp\cChoco\, C:\windows\temp\xPSDesiredStateConfiguration\ -Destination 'C:\Program Files\WindowsPowerShell\Modules\'

Function Get-CurrentInstanceTag(){

    #Gets all instance tags for the current instance
    $instanceId = Invoke-WebRequest "http://169.254.169.254/latest/meta-data/instance-id" -UseBasicParsing
    $versionTag = Get-EC2Tag | Where-Object {$Psitem.ResourceId -eq $instanceId -and $Psitem.Key -notlike 'aws*'} | Select-Object Key, Value
    return $versiontag
}

$CurrentTags = Get-CurrentInstanceTag

[String]$Application = $CurrentTags.Where{$Psitem.Key -eq 'Application'}.Value

#rename the mof we want from the .zip file
Rename-Item C:\windows\temp\$($Application).mof -NewName localhost.mof

# Open up any required Ports
New-NetFirewallRule -DisplayName 'Application port' -Direction Inbound -LocalPort 5000 -Protocol TCP -Action Allow -Verbose

#Apply DSC Configuration
Start-DscConfiguration -path C:\windows\temp\ -Verbose -wait -force -ComputerName localhost

#Stop all transcription
Stop-Transcript

#Write transcription to S3
Write-S3Object -BucketName powershell-dsc-mofs -File C:\Userdata_$Timestamp.txt

