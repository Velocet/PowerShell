#Requires -Version 5
#Requires -RunAsAdministrator

# Informationen unter: https://technet.microsoft.com/library/dn927162.aspx

#$Installed = Get-Package | Where-Object -Property ProviderName -NotMatch '(msu|msi|Programs)'
#$Online = Get-Package | Where-Object -Property ProviderName -NotMatch '(msu|msi|Programs)' | % { Find-Package $_.Name }
#Find-Package -Name GitHub -ForceBootstrap
#Module die man haben will: ChocolateyGet, platyPS, find-string

function Initialize-PSPackageManagement {
  <#
      .SYNOPSIS
      Install and initialize PowerShell package management and package manager.

      .DESCRIPTION
      Naming declaration:
      Package Managers = Package Providers
      OneGet (aka PackageManagement) = (Package) Manager / Multiplexer of existing Package Managers to unify Package Management
      PowerShellGet is the Package Manager for PowerShell (https://www.powershellgallery.com/)
      PowerShellGet module is integrated with the PackageManagement module as a provider
      Module Repository = something like PSGallery

      OneGet: Software Packages
      PowerShellGet: Modules
      
      Installs the following package manager:
      - PsGet
      - Chocolatey
      - PoShCode

      To list the other package manager provider, type:
      Find-PackageProvider

      If you want to set up your own package server, see:
      https://myget.org/
      http://inedo.com/proget

      See Links for further information.

      .LINK
      https://github.com/Velocet/PowerShell/

      .NOTES
      Needs Administrator privileges.

      Find-PackageProvider     # Package Management Package Providers available for installation.
      Get-PackageProvider      # Package Providers that are connected to Package Management.
      Get-PackageProvider -ListAvailable # Show available Package Provider.
      Install-PackageProvider  # Installs Package Management Package Provider.
      Import-PackageProvider   # Add Package Management Package Provider to the current session.

      Get-PackageSource        # Package sources that are registered for a Package Provider.
      Register-PackageSource   # Package source for a specified Package Provider.
      Set-PackageSource        # Replace a Package source.
      Unregister-PackageSource # Remove Package source.

      Find-Package             # Packages in available Package sources.
      Get-Package              # Packages installed by PackageManagement (OneGet)
      Install-Package          # Install Package.
      Save-Package             # Saves Package without installing.
      Uninstall-Package        # Uninstall Package.
  #>
  # choco apiKey -k 435c06f4-42b8-41e9-86f1-383b6e10f3ee -source https://chocolatey.org/
  
  if (!$PSUser) {
    $PSUser = Split-Path -Path $profile -Parent
    $PSUser = Join-Path -Path $PSUser -ChildPath $env:USERNAME
  }

  # Install PoshCode Module - http://poshcode.org/
  Install-WebModule -Uri 'http://poshcode.org/PoshCode.psm1' -ModuleName 'PoShCode' -Private

  InstallationPolicy-Wert, indem Sie das Set-PSRepository

  if (Test-Admin) {
    #region Chocolatey (https://chocolatey.org)
    
    # Configure Chocolatey Installation: Installation folder
    $env:ChocolateyInstall               = Join-Path -Path $PSUser -ChildPath 'Chocolatey' 
    # Configure Chocolatey Installation: Use Windows integrated compression instead of 7zip
    $env:chocolateyUseWindowsCompression = 'true'

    # Download and Install Chocolatey
    Invoke-Expression -Command ((New-Object -TypeName System.Net.WebClient).DownloadString('http://chocolatey.org/install.ps1'))

    # Configure Chocolatey
    $ChocolateyCache = Join-Path -Path $env:TEMP -ChildPath 'Chocolatey'
    & "$env:ChocolateyInstall\bin\choco.exe" config set --name 'cacheLocation' --value $ChocolateyCache
    
    # Add Chocolatey sources
    & "$env:ChocolateyInstall\bin\choco.exe" source add --name 'PsGet' --source 'http://psget.net/api/v2/'
    & "$env:ChocolateyInstall\bin\choco.exe" source add --name 'nuget' --source 'https://nuget.org/api/v2/'

    #endregion Chocolatey
      
    #region PsGet (https://psget.net)

    # Download PsGet
    Invoke-Expression -Command ((New-Object -TypeName System.Net.WebClient).DownloadString('http://psget.net/GetPsGet.ps1'))
    
    # Install PsGet Module
    Install-Module -Module 'PsGet'
    
    # Import PsGet Module
    Import-Module -ModuleInfo 'PsGet'

    #endregion PsGet

    #region Install Package Management package providers (PowerShell PackageManager provider)
    Install-PackageProvider -Name 'nuget'             # NuGet provider for the OneGet meta-package manager
    Install-PackageProvider -Name 'psl'               # psl provider for the OneGet meta-package manager
    Install-PackageProvider -Name 'Chocolatey'        # Chocolatey Prototype provider for the OneGet meta-package manager
    Install-PackageProvider -Name 'ContainerImage'    # Discover, download and install Windows Container OS images: https://github.com/PowerShell/ContainerProvider
    Install-PackageProvider -Name 'GitHubProvider'    # GitHub-as-a-Package - Interop with Github: https://github.com/dfinke/OneGetGitHubProvider
    Install-PackageProvider -Name 'NanoServerPackage' # Discover, Save and Install Nano Server Packages on-demand
    #Install-PackageProvider -Name 'TSDProvider'      # Search & install TypeScript definition files from the community DefinitelyTyped repo
    #Install-PackageProvider -Name 'MyAlbum'          # Discovers the photos in your remote file repository and installs them to your local folder
    Install-PackageProvider -Name 'OfficeProvider'    # Install Microsoft Office365 ProPlus from Powershell
    Install-PackageProvider -Name 'GistProvider'      # Gist-as-a-Package - Interop with Github Gists
    Install-PackageProvider -Name 'WSAProvider'       # Discover, Install and inventory windows server apps
    #Install-PackageProvider -Name 'GitLabProvider'   # GitLab PackageManagement provider
    #endregion
    
    #region Add Package Management package providers to the current session
    Import-PackageProvider -Name 'nuget'             # NuGet provider for the OneGet meta-package manager
    Import-PackageProvider -Name 'psl'               # psl provider for the OneGet meta-package manager
    Import-PackageProvider -Name 'Chocolatey'        # ChocolateyPrototype provider for the OneGet meta-package manager
    Import-PackageProvider -Name 'ChocolateyGet'     # OneGet provider that discovers packages from chocolatey.org
    Import-PackageProvider -Name 'ContainerImage'    # Discover, download and install Windows Container OS images: github.com/PowerShell/ContainerProvider
    Import-PackageProvider -Name 'GitHub'            # GitHub-as-a-Package - PackageManagement PowerShell Provider to interop with Github
    Import-PackageProvider -Name 'NanoServerPackage' # PackageManagement provider to  Discover, Save and Install Nano Server Packages on-demand
    #Import-PackageProvider -Name 'TSD'               # PowerShell PackageManager provider to search & install TypeScript definition files from the community DefinitelyTyped repo
    #Import-PackageProvider -Name 'MyAlbum'           # MyAlbum provider discovers the photos in your remote file repository and installs them to your local folder
    Import-PackageProvider -Name 'Office'            # OfficeProvider allows users to install Microsoft Office365 ProPlus from Powershell
    Import-PackageProvider -Name 'Gist'              # Gist-as-a-Package - PackageManagement  PowerShell Provider to interop with Github Gists
    Import-PackageProvider -Name 'WSA'               # Provider to Discover, Install and inventory windows server apps
    #Import-PackageProvider -Name 'GitLab'            # GitLab PackageManagement provider
    #endregion

    #region Add package source for the package provider
    Register-PackageSource -Name 'PsGet' -Provider 'PsGet' -Location 'http://psget.net/api/v2/'
    Register-PackageSource -Name 'nuget' -Provider 'nuget' -Location 'https://nuget.org/api/v2/'
    Register-PackageSource -Name 'chocolatey' -Provider 'Chocolatey' -Location 'https://chocolatey.org/api/v2/'
    
    # Trust all package sources
    Get-PackageSource | Set-PackageSource -Trusted 
    #endregion

    #region Register PowerShell repositories
    Register-PSRepository -Name 'Chocolatey' -SourceLocation http://chocolatey.org/api/v2/ -ScriptSourceLocation http://chocolatey.org/api/v2/items/psscript/ -ScriptPublishLocation http://chocolatey.org/api/v2/package/ -PublishLocation http://chocolatey.org/api/v2/package/ -InstallationPolicy Trusted
    Register-PSRepository -Name 'NuGet' -SourceLocation https://nuget.org/api/v2/ -ScriptSourceLocation https://nuget.org/api/v2/items/psscript/ -ScriptPublishLocation https://nuget.org/api/v2/package/ -PublishLocation https://nuget.org/api/v2/package/ -InstallationPolicy Trusted
    # Private MyGet Repo Example.
    #Register-PSRepository -Name 'DemoRepo' –SourceLocation 'https://www.myget.org/F/MyNuGetSource/api/v2/' -PublishLocation 'https://www.myget.org/F/MyNuGetSource/api/v2/Packages/' -InstallationPolicy Trusted
    
    # Set all repositories as trusted
    ###
    ### TODO NEEDS WORK!!!
    ###
    Get-PSRepository | % { Set-PSRepository -InstallationPolicy Trusted -Name $_.Name }
    #endregion
  }
  else { Write-Warning -Message 'No Admin! No Install!' }
}