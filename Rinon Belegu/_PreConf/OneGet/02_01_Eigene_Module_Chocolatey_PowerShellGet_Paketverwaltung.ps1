# Pfad fuer AutoLoad von Modulen seit PowerShell 3.0
$env:PSModulePath -split ';'

# Erstellen SystemTools Modul  Ordner
New-Item -Path $home\Documents\WindowsPowerShell\Modules\SystemTools -ItemType Directory

# Importieren Modul
Import-Module $home\Documents\WindowsPowerShell\Modules\SystemTools -Verbose

# Rangfolge Importieren von Modul

# 1 psd1 -> Manifest
# 2 psm1 -> falls manifest nicht verfügbar


# Geladene Module anschauen
Get-Module

# Test des eigenen Moduls
Get-InstalledSoftware -ComputerName localhost

# Modul nachladen falls Anpassungen (Caching) -> Modul wird pro Session nur einmal geladen
Import-Module $home\Documents\WindowsPowerShell\Modules\SystemTools -Verbose -Force

################################## Manifest Datei ##################################

# Modul details
Get-Module -Name SystemTools -ListAvailable

# Erstellen Manifest Datei
New-ModuleManifest -Path "$home\Documents\WindowsPowerShell\Modules\SystemTools\SystemTools.psd1" -Author 'Rinon' -Description 'Gibt Installierte Software eines Computers aus' -ModuleVersion 1.0.0

# Manifest Datei Testen
Test-ModuleManifest -Path "$home\Documents\WindowsPowerShell\Modules\SystemTools\SystemTools.psd1"

# Anpassen RootModule auf SystemTools.psm1
# In PowerShell 2.0 hiess es noch ModuleToProcess mann kann auch zur Abwärtskomp. ab PowerShell 3.0 umbenennen in ModuleToProcess.

# Modul Nachladen
Import-Module $home\Documents\WindowsPowerShell\Modules\SystemTools -Force

# Modul Infos anzeigen
Get-Module -Name SystemTools

# Aufabu der ManiFest Datei verstehen
$mani = "$home\Documents\WindowsPowerShell\Modules\SystemTools\SystemTools.psd1"
$inhalt = Get-Content -Path $mani -Raw # Raw liest Text als Ganzes, nicht Zeilenweise
$details = Invoke-Expression $inhalt

$details.GUID



