# Nano Server
# PSconf EU 2017
# Script Help for PowerShellGet

# Module von PowerShellGet (OneGet for PowerShell)
Get-Module -Name PowerShellGet -ListAvailable

# Packages anzeigen
Get-PackageProvider

# Nuget-Provider installieren
Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force

# Repositorys (Quellen) anzeigen
Get-PSRepository

# Module erforschen
Find-Module -Name Posh-SubnetTools -AllVersions | Select-Object -Property Version, Name, Author, PublishedDate, Description, ReleaseNotes, Copyright
Find-Module -Name NtpTime -AllVersions | Select-Object -Property Version, Name, Author, PublishedDate, Description, ReleaseNotes, Copyright

# Module fuer Analyse sichern

# Neuer Ordner
mkdir C:\ueberpruefen

# Modul sichern
Save-Module -Name Posh-SubnetTools -Path c:\ueberpruefen
Save-Module -Name NtpTime -Path c:\ueberpruefen

# Bestimmte Version von Modulen sichern
Save-Module -Name NtpTime -Path C:\ueberpruefen -MaximumVersion 1.0

# Importieren eines Moduls
Import-Module -Name C:\ueberpruefen\NtpTime -Verbose # -> Neuste Version wird automatisch importiert

# Testlauf
Get-Command -Module NtpTime
Get-Help -Name Get-NtpTime -Full
Get-NtpTime | Select-Object -Property *

# Installieren des Moduls für aktuellen Benutzer
Install-Module -Name ntpTime -Scope CurrentUser

# Installieren des Moduls für alle Benutzer
Install-Module -Name ntpTime -Scope AllUsers

# Installieren einer bestimmten Version
Install-Module -Name ntpTime -Scope AllUsers -RequiredVersion 1.0

# Module aktualisieren
Update-Module -Name ntpTime -Verbose

################################################ Mit eigenen Repositorys arbeiten ################################################

# FileShare
Register-PSRepository -Name LegendaryTeam -SourceLocation '\\hv01.legendary.local\LegendaryTeam' -InstallationPolicy Trusted

# Anzeigen der Repositorys
Get-PSRepository

# Publishen eines Moduls
Publish-Module -Path C:\ueberpruefen\NtpTime\1.1 -Repository LegendaryTeam -ReleaseNotes 'NTP Time Demo Release' -Tags demo,time,ntptime

# Manifest File .psd1
# Minimum Version,Author und Description

#Publishen unseres eigenen Moduls

Publish-Module -Name SystemTools -Repository LegendaryTeam -ReleaseNotes 'Toolkit fuer SystemAdministration' -Tags systools,software,programs

# Module aus dem Repository finden

Find-Module -Repository LegendaryTeam
Find-Module -Repository LegendaryTeam -Name NtpTime -AllVersions


########################################## Break before Choco ##########################################

# Ansicht installierter PacketAnbieter
Get-PackageProvider

# Auflisten verfügbarer Packetanbieter
Find-PackageProvider

# Installieren chocolatey Packetanbierter
Install-PackageProvider chocolatey -Scope CurrentUser

# Packete eines bestimmten Providers anzeigen
Find-Package -Source Chocolatey

# Aktuelle Anzahl Packete
(Find-Package -Source Chocolatey).count

# Find-Package -Source LegendaryTeam

# Suchen von Packeten
Find-Package *firefox*
Find-Package *steroids*

# Speichern von Packeten

Save-Package ISESteroids -Path C:\ueberpruefen

# Markieren einer PaketSource als Vertrauenswuerdig
Set-PackageSource -Name chocolatey -Trusted

# Ueberpruefen
Get-PackageSource 

# Beispiel Installation Basissoftware

$packages = ( "7zip", "adobereader", "Firefox", "filezilla", "flashplayerplugin", 
"foobar2000", "GoogleChrome", "javaruntime", "keepass", "microsoftazurestorageexplorer", 
"Opera", "paint.net", "skype", "teamviewer", "todoist", "vlc", "WhatsApp", "fiddler4" )
 
$packages | ForEach { Install-Package $_ }


# Links
# https://chocolatey.org/docs/how-to-host-feed
# 