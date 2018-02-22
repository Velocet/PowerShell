#Requires -RunAsAdministrator
#Requires -Version 3.0

# Version 2.0.0-beta
# TODO
# UnBlock-Adobe: amtdll ersetzen und painter.ini in richtiges verzeichnis kopieren
# Idee: Statt application.xml, amtdll suchen und dann unterverzeichnis bestimmen!

function Compress-Folder {

   Param(
	    [parameter(HelpMessage = "Directory to be compressed. Default: Current Directory.")]
	    [Alias('S')]
	    [String]$Directory = $pwd,
        [parameter(HelpMessage = "Compression Algorithm. Default: XPRESS8K")]
        [ValidateSet("XPRESS4K", "XPRESS8K", "XPRESS16K", "LZX")]
        [Alias('Exe')]
	    [String]$Algorithm='XPRESS8K',
        [parameter(HelpMessage = "Verbose mode. Default: No.")]
        [Alias('Q')]
	    [Switch]$Verbose=$false
    )

    if ($Directory -ne $pwd) {
        $Directory = $pwd
    }
    else {
        $Directory = Resolve-Path -Path $Directory
    }

    & "$("$env:SystemRoot\System32\compact.exe")" /C /I /S:$Directory $(if(!$Verbose){"/Q"} /EXE:$Algorithm )
   
}

function Unprotect-Adobe {
$painterini = @"
[Config]
; Use INI or use default options
UseCfg=1
Name=$Name
LEID=$LEID
Version=$Version
Serial=916387098118488076034526
; AdobeID (stub)
AdobeID=painter@adobe.com
PersonGUID=7189F1490B80A4FEC6B81B51@AdobeID
[AMT]
; AMT Library version
Version=10
; Enables the genuine AMTRetrieveLibraryPath algorithm
; 0 = disable
; 1 = enable
AMTRetrieveLibraryPath=0
"@

$applicationXml = Get-ChildItem -Filter 'application.xml' -Recurse

foreach ($file in $applicationXml) {
   [xml]$xml = Get-Content -Path $file.FullName
   $configPayload = $xml.Configuration.Payload.Data
   $configOther = $xml.Configuration.Other

   foreach ($key in $configPayload) {
    if ($key.key -eq 'driverLEID') {
        $LEID = $key.'#text'
    }
   }

   foreach ($key in $configPayload) {
    if ($key.key -eq 'ProductVersion') {
        $Version = $key.'#text'
    }
   }

   foreach ($key in $configOther) {
    if ($key.adobeCode -eq $LEID) {
     foreach ($data in $key.data) {
      if($data.key -eq 'EPIC_APP') {
       $Name = $data.'#text'
      }
     }
    }
   }

   Set-Content -Value $painterini -Path painter.ini -Encoding Ascii -Force

}
}

function New-NetFirewallAppRule {

    Param(
	    [parameter(Mandatory=$true,HelpMessage = "Directory to be blocked")]
	    [String]$dir,
        [parameter(Mandatory=$true,HelpMessage = "Blocked applications group name")]
	    [String]$group
    )

    begin {
        $ErrorActionPreference = "Stop" #Cancel execution if error occurs
    }

    process {
        
        try {
            # Get executables in $dir recursively
            $files = Get-ChildItem -Path $dir -Recurse -File -Filter "*.exe"

            # Create outbound rule for every executable in $files
            foreach ($file in $files) {
                $rule = New-NetFirewallRule -Action Block -Direction Outbound -Group $group -DisplayName $file.Name -Program $file.FullName
				Write-Host "Blocked:" $file.FullName
            }
        }
        
        catch {
            Write-Error $("ERROR:" + $_.Exception.GetType().FullName); 
	        Write-Error $("ERROR:" + $_.Exception.Message);            
        }
        
        finally {
            $error.clear()
        }
    }

    end {
        $dir = null
        $group = null
    }
} # Create firewall rules to block executables in the given directory and its sub-directories

# Delete old rules before creating new
Get-NetFirewallApplicationFilter -Program "*\Adobe\*" -PolicyStore ActiveStore | Remove-NetFirewallRule

New-NetFirewallAppRule -dir $("$env:ProgramFiles"+'\Adobe\') -group "Adobe"
New-NetFirewallAppRule -dir $(${env:ProgramFiles(x86)}+'\Adobe') -group "Adobe"
