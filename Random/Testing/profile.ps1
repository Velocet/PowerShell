. 'C:\Users\Velocet\OneDrive\Dokumente\WindowsPowerShell\Velocet\Scripts\Test-Admin.ps1'
. 'C:\Users\Velocet\OneDrive\Dokumente\WindowsPowerShell\Velocet\Scripts\Install-WebModule.ps1'

# (Get-WmiObject -Class Win32_UserAccount -Namespace "root\cimv2" -Filter "Disabled='$false'").Name

# Durchlauf falls kein Config File vorhanden: Heißt das PoSh/PackageManagement noch nicht eingerichtet ist
#if (!Test-Path $UserSettingsFile) {
if ($true) {

  $Verbose = $VerbosePreference
  $VerbosePreference = 'Continue'
  
  #. 'C:\Users\Velocet\OneDrive\Dokumente\WindowsPowerShell\Velocet\Scripts\Initialize\Initialize-PSConfigFile.ps1'
  . 'C:\Users\Velocet\OneDrive\Dokumente\WindowsPowerShell\Velocet\Scripts\Initialize\Initialize-PSPackageManagement.ps1'
  #. 'C:\Users\Velocet\OneDrive\Dokumente\WindowsPowerShell\Velocet\Scripts\Initialize\Initialize-PSEnviroment.ps1'
  # Aus dem profil aufrufen, checken ob bereits gelaufen, alls nicht alles konfigureren (preparing for first run, installing bla,..) und settings speichern

  # Check ob Skript selber aufgerufen wird oder aus script (also dem profil) aufgerufen wird
  #$UserSettingsFile
  #[xml]$UserSettings = Get-Content $UserSettingsFile
  #$UserSettings.settings.initialize
  #$MyInvocation.PSCommandPath # Script das dieses script aufgerufen hat
  #$PSCommandPath # dieses script
  #$UserSettingsFile = $PSCommandPath + '.xml'      # Invoking script config file
  
  #region Package Management package provider
  # TODO Hilfe sagt das der Import jeweils nur für die aktuelle Session gilt: Muss also import-packageprovider in das profil und bei jedem start geladen werden damit es zur verfügung steht?
  #Import-PackageProvider -Name 'chocolatey'  # Adds Chocolatey Package Management package provider to the current session
  #endregion Package Management package provider

  $VerbosePreference = $Verbose

} # Falls Settings File nicht vorhanden: Initialisierungssckript starten
# Eventuell Initialisierungsskript ins profil integrieren?