if ($env:ChocolateyInstall) { $Global:ChocolateyProfile = "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
if (Test-Path -Path $ChocolateyProfile) { Import-Module -Name $ChocolateyProfile } }

$PSUser="$(Split-Path $profile)\$env:USERNAME";if(Test-Path $PSUser){. "$PSUser\PowerShell_profile.ps1"}