#Requires -Version 5
#Requires -RunAsAdministrator

# todo
# beim ausführen automatisch zertifikat importieren

<#
    Module die man haben will:
    PoSh-Git
    
    # standard bei w10
    PSReadLine: Get-PSReadlineKeyHandler | where Key -NotLike 'Unbound' # Alle shortcuts anzeigen

    Set-PSReadlineOption -DingTone 440
    Set-PSReadlineOption -DingDuration 88
    Set-PSReadlineOption -ContinuationPrompt '» '
    Set-PSReadlineOption -HistorySavePath "$PSUserLogs\ConsoleHost_history.txt"
    Set-PSReadlineOption -HistorySaveStyle SaveNothing
    Set-PSReadlineOption -MaximumHistoryCount 512
#>

function Initialize-PSEnviroment {
  <#
      .SYNOPSIS
      Configure PoSh for the first run to use with your profile.

      .DESCRIPTION
      Configure PoSh for the first run to use with your profile.
      1. Set Execution Policy to 'Bypass'

      .EXAMPLE
      Initialize-PoSh
      Configure your PoSh profile.

      .EXAMPLE
      Edit Initialize-PoSh

      .NOTES
      Before the first run you should configure the script.

      .LINK
      https://github.com/velocet/powershell
      PowerShell
  #>
  
  #region Settings & Variables
  # Set User Profile and supporting (Scripts, Modules, etc.) Paths
  # Personal variables are prefixed with 'PSUser'
  $PSUser            = Split-Path -Path $profile -Parent
  $PSUser            = "$PSUser\$PSUserName" # User Directory Path
  $PSUserInitialize  = "$PSUser\Initialize"  # User Initialize Path
  $PSUserLogs        = "$PSUser\Logs"        # User Logs Path
  $PSUserModules     = "$PSUser\Modules"     # User Modules Path
  $PSUserScripts     = "$PSUser\Scripts"     # User Scripts Path
  $PSUserProfile     = $PSCommandPath        # User Profile (normally this file)
  $PSUserGit         = "$([Environment]::GetFolderPath('MyDocuments'))\GitHub"
  $PSUserOneDrive    = Get-ItemPropertyValue -Path 'HKCU:\Software\Microsoft\OneDrive' -Name 'UserFolder'  
  #endregion
  
  # Normally all files should be already unblocked via install.ps1 but just to be sure...
  Get-ChildItem -Path $PSUser -Recurse | Unblock-File
  
  Write-Verbose -Message 'Add the user modules path to the user PSModulePath enviroment variable'
  $PSUserTmp = [Environment]::GetEnvironmentVariable('PSModulePath','User')
  if ($PSUserTmp -NotLike "*$PSUserModules*") {
    [Environment]::SetEnvironmentVariable('PSModulePath',"$PSUserModules;$PSUserTmp",'User')
  }

  if (Test-Path -Path $PSUserInitialize) {
    $Items = (Get-ChildItem -File -Filter '*.ps1' -Path $PSUserInitialize -Recurse).FullName
    foreach ($Item in $Items) { . $Item }
  } # Load all initializion scripts

  else {
    Write-Warning ''
    Write-Warning ' !Initialize-Folder is missing or $PSUserInitialize not/wrong set!'
    Write-Warning ''
    Write-Warning '                  Only configuring a minimal set                  '
    Write-Warning ''
  }

  # Config File erstellen lassen und im profile abfragen lassen

  if (('Unrestricted','Bypass') -notcontains (Get-ExecutionPolicy)) {
    Set-ExecutionPolicy -ExecutionPolicy 'Bypass' -Force
  } # Set Execution Policy: Nothing is blocked and there are no warnings or prompts.

}

function asd-asd {

 
  Import-PackageProvider -Name 'nuget'             # NuGet provider for the OneGet meta-package manager
  Import-PackageProvider -Name 'psl'               # psl provider for the OneGet meta-package manager
  Import-PackageProvider -Name 'Chocolatey'        # ChocolateyPrototype provider for the OneGet meta-package manager
  Import-PackageProvider -Name 'ChocolateyGet'     # ChocolateyPrototype provider for the OneGet meta-package manager
  Import-PackageProvider -Name 'ContainerImage'    # Discover, download and install Windows Container OS images: https://github.com/PowerShell/ContainerProvider
  Import-PackageProvider -Name 'GitHub'            # GitHub-as-a-Package - PackageManagement PowerShell Provider to interop with Github
  Import-PackageProvider -Name 'NanoServerPackage' # PackageManagement provider to  Discover, Save and Install Nano Server Packages on-demand
  #Import-PackageProvider -Name 'TSDProvider'       # PowerShell PackageManager provider to search & install TypeScript definition files from the community DefinitelyTyped repo
  #Import-PackageProvider -Name 'MyAlbum'           # MyAlbum provider discovers the photos in your remote file repository and installs them to your local folder
  Import-PackageProvider -Name 'OfficeProvider'    # OfficeProvider allows users to install Microsoft Office365 ProPlus from Powershell
  Import-PackageProvider -Name 'Gist'              # Gist-as-a-Package - PackageManagement  PowerShell Provider to interop with Github Gists
  Import-PackageProvider -Name 'WSAProvider'       # Provider to Discover, Install and inventory windows server apps
  #Import-PackageProvider -Name 'GitLabProvider'    # GitLab PackageManagement provider
  

}