
#install.ps1
#
# PoSh profile datei profile.ps1 nehmen: kann für PoSh und ISE verwendet werden!
# somit nur in dieser datei die beiden profil dateien verlinken.
# ISE datei darf dann nur ISE spezifische sachen enthalten
# bei installationsproblemen:
# powershell -noprofile -command "Install-Module PowerShellGet -Force"
# powershell -noprofile -command "Install-Module PSReadline -SkipPublisherCheck -Force"
# In profile.ps1 hinzufügen: $PSUser=[Environment]::GetFolderPath(“MyDocuments”)+"\GitHub\PowerShell\$env:USERNAME";if(Test-Path $PSUser){. "$PSUser\profile.ps1"}

if ($host.Name -eq 'ConsoleHost')
{
    Import-Module PSReadline
}

# Unblock all downloaded files
Get-ChildItem -Path $PSUser -Recurse | Unblock-File

abfragen ob ise oder posh

#github zip laden + entpacken in Dokumente\WindowsPowerShell\$env:USERNAME
#vorher auf variable PSUserName prüfen: falls diese vorhanden, in diesen verzeichnis installieren
#prüfen ob Microsoft.PowerShell_profile.ps1 bereits erstellt ist.
# falls nicht: erstellen mit $PROFILE variable
# zeile hinzufügen die automatisch die PowerShell_profile.ps1 aus dem Profil lädt
#prüfen ob Microsoft.PowerShellISE_profile.ps1 bereits erstellt ist.
# falls nicht: erstellen mit $PROFILE variable
# zeile hinzufügen die automatisch die PowerShell_profile.ps1 aus dem Profil lädt
#initialize script starten? oder nen hinweis darauf vermerken
# initialize script updated erstmal alles, installiert dann alle
# package provider, setzt die sourcen, usw.
# dann werden module installiert die man vorher in der initialize definieren kann
# Hinweis vor ausführung der initialize datei mit auflistung der pakete die installiert werden
# Frage ob fortgefahren werden soll oder nicht.
# ansonsten alles andere initializieren
# SetPSReadline foo korrekt setzen