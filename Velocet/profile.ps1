#DIESE DATEI ENTHÄLT ISE UND POSH
#Requires -Version 5

<# ToDo
    Script signieren

    # Die Tools von WSCC zum pfad hinzufügen
    $env:Path         = $env:Path         + ";C:\Users\Stephen\.dotfiles\powershell\profiles;C:\Users\Stephen\.dotfiles\bin"

    ---

    # GitHub for Windows https://windows.github.com/
    . (Resolve-Path "$env:LOCALAPPDATA\GitHub\shell.ps1")
    Write-Host -ForegroundColor DarkRed "--> [GitHub]"

    # Load posh-git example profile
    . 'C:\Users\Stephen\dev\posh-git\profile.example.ps1'
    Write-Host -ForegroundColor DarkRed "--> [PoSh-Git]"

    --
    Module:
    https://github.com/PoshCode/ModuleBuilder
    https://github.com/PoshCode/tldr
    https://github.com/PoshCode/PowerShellPracticeAndStyle
    https://github.com/PoshCode
    http://dahlbyk.github.io/posh-git/

    https://github.com/janjoris/oh-my-posh/#installation

    Git:
    https://git-scm.com/book/be/v2/Git-Internals-Environment-Variables
    https://git-scm.com/book/en/v2/Git-Tools-Submodules
    https://git-scm.com/book/uz/v2/Customizing-Git-Git-Configuration
    https://blog.kilasuit.org/2016/01/14/my-workflow-for-using-git-with-github-pt3/

    https://dillieodigital.wordpress.com/2015/10/20/how-to-git-and-ssh-in-powershell/
    http://mikefrobbins.com/2016/02/09/configuring-the-powershell-ise-for-use-with-git-and-github/

    Cmdlet aus Funktionen machen
    Prompt überarbeiten
    Fensterpositiion mittig setzen
    SMART Werte auslesen
    http://community.idera.com/powershell/powertips/b/tips/posts/creating-your-private-powershellget-repository
    RegEx Tester: https://regex101.com/
    # Load posh-git example profile
    . 'C:\Users\Velocet\OneDrive\Dokumente\WindowsPowerShell\Velocet\Modules\posh-git\profile.example.ps1'

#># ToDo

trap { Continue } # Handle errors: Pause but continue script execution

#region Settings
$PSUserName         = $env:USERNAME # User Name = Profile Folder, normally $env:username

$Log                = $false         # Enable Transcript
$UTF8Support        = $true          # Enable UTF-8 Support
$LoadGit            = $true          # Enable Git Functions (eg. PoSh-Git)
$Verbose            = $false         # Enable Verbose Output
#$ErrorView          = 'CategoryView' # Enable Succinct, structured view for errors
$ForegroundColor    = 'White'        # Console Foreground Color
$BackgroundColor    = 'Black'        # Console Background Color
#endregion

#region Variables
<#  Automatic Variables:   about_Automatic_Variables, Preference Variables: about_Preference_Variables
    Environment Variables: about_Environment_Variables,   Remote Variables: about_Remote_Variables
    $VARIABLE: Get-Variable, $env:VARIABLE: Get-ChildItem Env:
#> # Variables Overview

# Set User Profile and supporting (Scripts, Modules, etc.) Paths
# Personal variables are prefixed with 'PSUser'
$PSUser            = [Environment]::GetFolderPath(“MyDocuments”)+"\GitHub\PowerShell\$env:USERNAME"
#$PSUser            = Split-Path -Path $profile -Parent
#$PSUser            = "$PSUser\$PSUserName" # User Directory Path
$PSUserInitialize  = "$PSUser\Initialize"  # User Initialize Path
$PSUserLogs        = "$PSUser\Logs"        # User Logs Path
$PSUserModules     = "$PSUser\Modules"     # User Modules Path
$PSUserScripts     = "$PSUser\Scripts"     # User Scripts Path
$PSUserProfile     = $PSCommandPath        # User Profile (normally this file)
$PSUserGit         = "$([Environment]::GetFolderPath('MyDocuments'))\GitHub"
$PSUserOneDrive    = Get-ItemPropertyValue -Path 'HKCU:\Software\Microsoft\OneDrive' -Name 'UserFolder'
$null              = New-PSDrive -Name 'OneDrive' -PSProvider FileSystem -Root $PSUserOneDrive -Description 'OneDrive Root Folder'
$null              = Set-PSReadlineOption -DingTone 440 -DingDuration 88 -ContinuationPrompt '     +  ' -HistorySaveStyle 'SaveNothing'

###
$PsGetDestinationModulePath    = $PSUserModules         # Install modules in $PSUserModules by default (PsGet)
$PSModuleAutoLoadingPreference = 'All'                  # Module auto-loading preference
###

if ("$env:PSModulePath" -NotLike "*$PSUserModules*") {
  $env:PSModulePath  = "$PSUserModules;$env:PSModulePath" # Add User Modules Path to import all modules automatically
} # Check if "Initialize-PSEnviroment" was already run and add the users modules path if this is a temp profile

########## TODO statt datei, gci hklm: abfragen? ##########
if (!(Test-Path -Path "$PSUser\profile.psc1")) {
  while (!([console]::KeyAvailable)) {
    Write-Progress -Activity '! Enviroment not initialied !' -Status '! Please run Initialize-Enviroment !'
    Start-Sleep -Milliseconds 250
} } # Output Error if profile isn't initialized
else {
  $XML = [xml](Get-Content "$PSUser\profile.psc1")
  
  # GithubProvider: https://github.com/weswigham/GithubProvider
  $env:GITHUB_TOKEN = $XML.PSConsoleFile.Token.GitHub

  # PowerShell Gallery
  $PSDefaultParameterValues['Publish-Module:NuGetApiKey'] = $XML.PSConsoleFile.Token.PowerShellGallery
  $PSDefaultParameterValues['Publish-Script:NuGetApiKey'] = $XML.PSConsoleFile.Token.PowerShellGallery
  
  $env:NuGet_TOKEN = $XML.PSConsoleFile.Token.NuGet
  $env:MyGet_TOKEN = $XML.PSConsoleFile.Token.MyGet
   
  # Nur einmal ausführen
  #choco apikey -k "$XML.PSConsoleFile.Token.GitHub" -s https://chocolatey.org/
}

if ($UTF8Support) {
  $null                     = & "$env:windir\system32\chcp.com" 65001
  [Console]::OutputEncoding = [Text.UTF8Encoding]::UTF8
  $OutputEncoding           = [Text.UTF8Encoding]::UTF8
  #[Console]::InputEncoding  = [Text.UTF8Encoding]::UTF8 # Be careful with this one...
} # Enable PoSh UTF-8 support
if ($Verbose) {
  $Verbose = $VerbosePreference
  $VerbosePreference = 'Continue'
}     # Enable PoSh Verbose output
if ($Log) {
  Start-Transcript -OutputDirectory $PSUserLogs -IncludeInvocationHeader -NoClobber
}         # Enable PoSh session transcript
else {
  $LogCommandHealthEvent     = $false # Command errors
  $LogCommandLifecycleEvent  = $false # Starting and completion of commands
  $LogEngineHealthEvent      = $false # PowerShell program errors
  $LogEngineLifecycleEvent   = $false # Starting and stopping of PowerShell
  $LogProviderHealthEvent    = $false # PowerShell provider errors
  $LogProviderLifecycleEvent = $false # Starting and stopping of PowerShell providers
}              # Enable PoSh Event Logs
#endregion Variables

#region Modules / Scripts / 3rd Party
if (Test-Path -Path $PSUserScripts) {
  $Scripts = (Get-ChildItem -Path $PSUserScripts -Filter '*.ps1' -File -Recurse).FullName
  foreach ($Script in $Scripts) { . $Script }
} # Scripts

if ($LoadGit) {
  # Set up a 'Git:\' drive to point to the Git root folder
  $null = New-PSDrive -Name 'Git' -PSProvider FileSystem -Root $PSUserGit -Description 'Git Root Folder'

  # PoSh-Git
  #$PoshGit = "$PSUserModules\PoSh-Git"
  Import-Module -Name 'PoSh-Git'
  #Start-SshAgent -Quiet

  # GitHub
  if (Test-Path -Path "$env:LOCALAPPDATA\GitHub\shell.ps1") {
    . "$env:LOCALAPPDATA\GitHub\shell.ps1" # Load GitHub shell script
    $env:github_posh_git = $PoshGit        # Overwrite if set wrong by GitHub
  }
} # Git
#endregion Modules

#region Aliases
New-Alias -Name 'e'       -Value Invoke-Explorer
New-Alias -Name 'edit'    -Value "${env:windir}\notepad.exe" # https://www.binaryfortress.com/NotepadReplacer/
New-Alias -Name 'fortune' -Value Get-Fortune
New-Alias -Name 'gh'      -Value Get-Help
New-Alias -Name 'ghp'     -Value Invoke-GetHelpParameter
New-Alias -Name 'ghe'     -Value Invoke-GetHelpExamples
New-Alias -Name 'grep'    -Value Get-String
New-Alias -Name 'gua'     -Value Invoke-GitUpdateAll
New-Alias -Name 'hosts'   -Value Edit-Hosts
New-Alias -Name 'pro'     -Value Edit-Profile
New-Alias -Name 'qs'      -Value Quote-String
New-Alias -Name 'ql'      -Value Quote-List
New-Alias -Name 'resi'    -Value Reset-ISESteroidsTrialPeroid
New-Alias -Name 'subl'    -Value Invoke-Sublime
New-Alias -Name 'touch'   -Value New-File
New-Alias -Name 'uh'      -Value Invoke-UpdateHelp
New-Alias -Name 'vsc'     -Value Invoke-VSCode
New-Alias -Name 'vs'      -Value Invoke-VisualStudio
#endregion Aliases

#region Alias Functions
function Invoke-Explorer { Invoke-Item -Path '.' } # Explorer in current folder
function Invoke-GetHelpParameter { Get-Help "$args" | ft }
function Invoke-GetHelpExamples { Get-Help "$args" -Examples } # Get-Help Examples
function Invoke-GitUpdateAll { Git.exe add -A . } # Git: Update All
function Reset-ISESteroidsTrialPeroid { Remove-Item -Path 'HKLM:\SOFTWARE\Classes\CLSID\{f655a448-58b7-134f-63cf-59cbff42b85b0}' }
function Invoke-Sublime { & "${env:ProgramFiles}\Sublime Text 3\sublime_text.exe" "$args" } # Start Sublime Editor
function Invoke-VisualStudio {	Invoke-Item -Path '*.sln' } # VS for sln(s) in current folder
function Invoke-VSCode { code.exe --reuse-window "$args" } # Start Visual Studio Code
function Edit-Hosts { & 'notepad.exe' "${env:windir}\System32\drivers\etc\hosts" } # Edit hosts File
function Quote-String { "$args" }
function Quote-List { $args }
function Reset-OneDrive { Invoke-Command "$env:LOCALAPPDATA\Microsoft\OneDrive\onedrive.exe /reset" }

#region Push-Location
function .. { Push-Location -Path ..}
function ... { Push-Location -Path ..\..}
function .... { Push-Location -Path ..\..\..}
function ..... { Push-Location -Path ..\..\..\..}
#endregion Push-Location
#endregion Alias Functions

#region Filters
filter match( $reg ) { if ($_.tostring() -match $reg) { $_ } }          # grep like command but work on objects
filter exclude( $reg ) { if (-not ($_.tostring() -match $reg)) { $_ } } # grep -v like command but work on objects
filter like( $glob ) { if ($_.toString() -like $glob) { $_ } }          # behave like match but use only -like
filter unlike( $glob ) { if (-not ($_.tostring() -like $glob)) { $_ } } # behave like notmatch but use only -like
#endregion Filters

#region Functions
function Update-PSEnviroment {
  $Verbose = $VerbosePreference
  $VerbosePreference = 'Continue'

  #region NuGet
  Write-Output 'Checking NuGet version...'
  $InstalledVersion = [Version](Get-PackageProvider -Name 'NuGet' -ErrorAction SilentlyContinue).Version
  $OnlineVersion = [Version](Find-PackageProvider -Name 'NuGet' -ErrorAction SilentlyContinue).Version
  if(!$?) { Write-Warning -Message $Error[0]; Pause }

  if ($OnlineVersion -gt $InstalledVersion) {
    Write-Output "Before other packages could be updated, the NuGet provider has to be updated first.`n"
    Write-Output "PowerShell will exit after updating and you have to restart the update process.`n"
    Write-Output "Continue?`n"
    $Key = $HOST.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')
    $HOST.UI.RawUI.Flushinputbuffer()

    if ($Key.VirtualKeyCode -notlike '27') { # VirtualKeyCode 27 = Escape
      # Install the latest NuGet provider before updating PowerShellGet/PackageManagement
      Install-PackageProvider -Name 'NuGet' –Force -Verbose

      Write-Output -InputObject "`nPowerShell will now quit...`n"
      Pause
      exit
    }
    else {
      Write-Warning -Message 'Aborting update...'
      break
    }
  }
  #endregion

  #region PowerShellGet
  # PowerShellGet has a dependency on PackageManagement (OneGet), so installing it will also update/install OneGet
  $InstalledVersion = [Version](Get-Module -Name 'PowerShellGet' -ErrorAction SilentlyContinue).Version
  $OnlineVersion = [Version](Find-Module -Name 'PowerShellGet' -ErrorAction SilentlyContinue).Version
  if(!$?) { Write-Warning -Message $Error[0]; Pause }

  if ($OnlineVersion -gt $InstalledVersion) {
    Write-Output "Before other packages could be updated, the PowerShellGet module has to be updated first.`n"
    Write-Output "PowerShell will exit after updating and you have to restart the update process.`n"
    Write-Output "Continue?`n"
    $Key = $HOST.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')
    $HOST.UI.RawUI.Flushinputbuffer()

    if ($Key.VirtualKeyCode -notlike '27') { # VirtualKeyCode 27 = Escape
      # Install the latest PowerShellGet module before updating PSEnviroment
      #Install-Module –Name 'PowerShellGet' –Force -Verbose
      ###
      ### TODO NEEDS WORK!!!
      ###

      Write-Output -InputObject "`nPowerShell will now quit...`n"
      Pause
      exit
    }
    else {
      Write-Warning -Message 'Aborting update...'
      break
    }
  }
  #endregion

  #region Modules/Scripts
  # Update all installed modules
  Update-Module -Module *
  Update-Script -Name *
  #endregion

  # Chocolatey
  Write-Output -InputObject 'Updating Chocolatey...'
  choco.exe upgrade chocolatey --verbose # Update Chocolatey first
  Write-Output -InputObject 'Updating Chocolatey packages...'
  choco.exe upgrade all --verbose

  # PackageManagement
  Get-Package | Where-Object -Property ProviderName -NotMatch "(msu|msi|Programs)"

  Update-Help
  Update-MpSignature

  #Clean function einbauen

  #Function oder so einbauen die beim start von powershell checkt ob clean/upgrade function
  # seit ner woche nicht mehr lief (per registry?), darauf hinweist und fragt ob automatisch ausgeführt werden soll
  #checken ob eigene zertifikate bald ablaufen (und automatisch neu erstellen, falls das der fall ist):
  # Get-ChildItem -ExpiringInDays 30 Cert:\LocalMachine\My\
  # Get-ChildItem -ExpiringInDays 30 Cert:\CurrentUser\My\

  $VerbosePreference = $Verbose
}
#endregion Functions

if ($host.Name -Like 'ConsoleHost') {. "$PSUser\PowerShell_profile.ps1"}
else {. "$PSUser\PowerShellISE_profile.ps1"}

If ($Verbose) { $VerbosePreference = $Verbose }             # Reset Verbose Output
If ($Error) { $Error | Get-ErrorInfo }                      # Output script errors