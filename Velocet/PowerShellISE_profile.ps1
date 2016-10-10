
#http://community.idera.com/powershell/powertips/b/tips/posts/color-week-using-transparency-in-the-powershell-ise-console
#http://community.idera.com/powershell/powertips/b/tips/posts/color-week-using-clear-names-for-powershell-ise-colors
#    Farben für ISE: [System.Windows.Media.Colors]::Yellow.ToString()

<#  PoShISE profiles and their start order: "$profile | fl -Force". ISE options: "$psISE.Options"
    # Variable                Path
    1 AllUsersAllHosts        $PsHome\profile.ps1
    2 AllUsersCurrentHost     $PsHome\Microsoft.PowerShellISE_profile.ps1
    3 CurrentUserAllHosts     [Environment]::GetFolderPath(“MyDocuments”)\WindowsPowerShell\profile.ps1
    4 CurrentUserCurrentHost  [Environment]::GetFolderPath(“MyDocuments”)\WindowsPowerShell\Microsoft.PowerShellISE_profile.ps1
#>

trap { Continue } # Handle errors: Pause but continue script execution

#region psISE
$ISESteroidsOnLoad   = $true
$ISESteroidsOnDemand = $false

$psISE.Options.Zoom = 120
#endregion

#region Settings
$PSUserName         = $env:USERNAME # User Name = Profile Folder, normally $env:username

$UTF8Support        = $false        # Enable UTF-8 Support
$LoadGit            = $true         # Enable Git Functions (eg. PoSh-Git)
$Verbose            = $false        # Enable Verbose Output

# GithubProvider: https://github.com/weswigham/GithubProvider
$env:GITHUB_TOKEN = '01469e0dbb22af1bb40123f7a413b50987eb5fab'
#endregion

#region Variables
# Set User Profile and Supporting (Scripts, Modules, etc.) Paths
# User variables are prefixed with 'PSUser'
$PSUser            = Split-Path -Path $profile -Parent
$PSUser            = "$PSUser\$PSUserName"  # User Directory Path
$PSUserLogs        = "$PSUser\Logs"       # User Logs Path
$PSUserModules     = "$PSUser\Modules"    # User Modules Path
$PSUserScripts     = "$PSUser\Scripts"    # User Scripts Path
$PSUserInitialize  = "$PSUser\Initialize" # User Initialize Path
$PSUserGit         = "$([Environment]::GetFolderPath('MyDocuments'))\GitHub"
$PSUserProfile     = $PSCommandPath                     # User Profile (normally this file)
$PSModulePath      = "$PSUserModules;$env:PSModulePath" # Add User Modules Path
$PsGetDestinationModulePath    = $PSUserModules         # Install modules in $PSUserModules by default (PsGet)
$PSModuleAutoLoadingPreference = 'All'                  # Module auto-loading preference
$ISESteroidsPath   = "$PSUser\ISESteroids"
$PSUserOneDrive    = Get-ItemPropertyValue -Path 'HKCU:\Software\Microsoft\OneDrive' -Name 'UserFolder'

#region PSDefaultParameterValues
$PSDefaultParameterValues['Install-Module:Destination']     = $PSUserModules     # Install modules in $PSUserModules by default
$PSDefaultParameterValues['Install-Package:Force']          = $true              # Install software package without user prompts
$PSDefaultParameterValues['Install-Package:Scope']          = 'CurrentUser'      # Install software package in the current users scope
$PSDefaultParameterValues['Install-PackageProvider:Force']  = $true              # Install Package Management package provider without prompts
$PSDefaultParameterValues['Install-PackageProvider:Scope']  = 'AllUsers'         # Install Package Management package provider for all users
$PSDefaultParameterValues['Install-Script:Force']           = $true              # Install scripts without user prompts
$PSDefaultParameterValues['Install-Script:Scope']           = 'CurrentUser'      # Install scripts in the current users scope
$PSDefaultParameterValues['Format-List:Property']           = '*'                # Show all properties
$PSDefaultParameterValues['Get-Command:ShowCommandInfo']    = $true              # Show syntax and additional info
$PSDefaultParameterValues['Get-Command:ErrorAction']        = 'SilentlyContinue' # Surpress Errors and continue
$PSDefaultParameterValues['Get-Help:Parameter']             = '*'                # Only show parameters if viewing help
$PSDefaultParameterValues['Test-Path:ErrorAction']          = 'SilentlyContinue' # Surpress Errors and continue
$PSDefaultParameterValues['Update-Help:ErrorAction']        = 'SilentlyContinue' # Surpress Errors and continue
$PSDefaultParameterValues['Update-Help:Force']              = $true              # Update help without user prompts
$PSDefaultParameterValues['Update-Help:UICulture']          = [Globalization.CultureInfo[]]((Get-UICulture),'en-US')
$PSDefaultParameterValues['New-ModuleManifest:Author']      = $PSUserName
$PSDefaultParameterValues['New-ModuleManifest:CompanyName'] = $PSUserName + ' Consulting'
$PSDefaultParameterValues['New-ModuleManifest:Copyright']   = '{0:yyyy}' -f (Get-Date)
#endregion PSDefaultParameterValues
#
# statt datei, gci hklm: abfragen?
# HIER FEHLT NOCH NE FUNKTION FÜR ISE. ALS ABFRAGE SOLLTE HIER DIE THEME XML DIENEN: EINFACH AUF DIESE PRÜFEN
#
#if (!(Test-Path -Path "$PSCommandPath.xml")) {
#  while (!([console]::KeyAvailable)) {
#    Write-Progress -Activity '! Enviroment not initialied !' -Status '! Please run Initialize-Enviroment !'
#    Start-Sleep -Milliseconds 500
#} } # Output Error if profile isn't initialized

if ($UTF8Support) {    
  & "$env:windir\system32\chcp.com" 65001 > $null
  [Console]::OutputEncoding = [Text.UTF8Encoding]::UTF8
  #[Console]::InputEncoding  = [Text.UTF8Encoding]::UTF8 # Be careful with this one...
} # Enable PoSh UTF-8 support
if ($Verbose) {
  $Verbose = $VerbosePreference
  $VerbosePreference = 'Continue'
}     # Enable PoSh Verbose output
else {
  $LogCommandHealthEvent     = $false # Command errors
  $LogCommandLifecycleEvent  = $false # Starting and completion of commands
  $LogEngineHealthEvent      = $false # PowerShell program errors
  $LogEngineLifecycleEvent   = $false # Starting and stopping of PowerShell
  $LogProviderHealthEvent    = $false # PowerShell provider errors
  $LogProviderLifecycleEvent = $false # Starting and stopping of PowerShell providers
}              # Enable PoSh Event Logs

#region Console

#TODO
#Thema Farbe: per XML datei theme setzen
#TODO

$Host.DebuggerEnabled      = $false

#endregion Console
#endregion Variables

#region Modules / Scripts
if (Test-Path -Path $PSUserModules) {
  $Dir = Get-ChildItem -Path $PSUserModules -Directory
  foreach ($Folder in $Dir) {
    Import-Module -Name $Folder.FullName
  } # Import all modules
} # Modules

if (Test-Path -Path $PSUserScripts) {
  $Scripts = (Get-ChildItem -Path $PSUserScripts -Filter '*.ps1' -File -Recurse).FullName
  foreach ($Item in $Scripts) {. $Item}
} # Scripts

if ($LoadGit) {
  # Set up a 'Git:\' drive to point to the Git root folder
  $null = New-PSDrive -Name 'git' -PSProvider FileSystem -Root $PSUserGit -Description 'Git Root Folder'
  
  # PoSh-Git
  #Start-SshAgent -Quiet
  
  # GitHub  
  if (Test-Path -Path "$env:LOCALAPPDATA\GitHub\shell.ps1") {
    $PoshGit = Split-Path -Path (Get-Module -Name 'PoSh-Git').Path -Parent
    $env:github_posh_git = $PoshGit        # Needed for GitHub profile/shell.ps1
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
New-Alias -Name 'ghe'     -Value Invoke-GetHelpExamples
New-Alias -Name 'grep'    -Value Get-String
New-Alias -Name 'gua'     -Value Invoke-GitUpdateAll
New-Alias -Name 'hosts'   -Value Edit-Hosts
New-Alias -Name 'pro'     -Value Edit-Profile
New-Alias -Name 'qs'      -Value Quote-String
New-Alias -Name 'ql'      -Value Quote-List
New-Alias -Name 'subl'    -Value Invoke-Sublime
New-Alias -Name 'touch'   -Value New-File
New-Alias -Name 'uh'      -Value Invoke-UpdateHelp
New-Alias -Name 'vsc'     -Value Invoke-VSCode
New-Alias -Name 'vs'      -Value Invoke-VisualStudio
#endregion Aliases

#region Alias Functions
function Invoke-Explorer { Invoke-Item -Path '.' }          # Explorer in current folder
function Invoke-GetHelpExamples { Get-Help -Examples }      # Get-Help Examples
function Invoke-GitUpdateAll { Git.exe add -A . }           # Git: Update All
function Invoke-Sublime { & "${env:ProgramFiles}\Sublime Text 3\sublime_text.exe" $args } # Start Sublime Editor
function Invoke-VisualStudio {	Invoke-Item -Path '*.sln' } # VS for sln(s) in current folder
function Invoke-VSCode { code.exe --reuse-window $args }    # Start Visual Studio Code
function Edit-Hosts { & 'notepad.exe' "${env:windir}\System32\drivers\etc\hosts" }        # Edit hosts File
function Edit-Profile { & 'notepad.exe' $PROFILE }           # Open Profile
function Quote-String { "$args" } 
function Quote-List { $args }
function Reset-OneDrive { Invoke-Command "$env:LOCALAPPDATA\Microsoft\OneDrive\onedrive.exe /reset" }

#region Push-Location  
function .. { Push-Location -Path ..}
function ... { Push-Location -Path ..\..}
function .... { Push-Location -Path ..\..\..}
function ..... { Push-Location -Path ..\..\..\..}
function ...... { Push-Location -Path ..\..\..\..\..}
function ....... { Push-Location -Path ..\..\..\..\..\..}
#endregion Push-Location
#endregion Alias Functions
  
#region Filters
filter match( $reg ) { if ($_.tostring() -match $reg) { $_ } }          # grep like command but work on objects
filter exclude( $reg ) { if (-not ($_.tostring() -match $reg)) { $_ } } # grep -v like command but work on objects
filter like( $glob ) { if ($_.toString() -like $glob) { $_ } }          # behave like match but use only -like
filter unlike( $glob ) { if (-not ($_.tostring() -like $glob)) { $_ } } # behave like notmatch but use only -like
#endregion Filters

#region ISESteroids
if ($ISESteroidsOnLoad) {

  Import-Module -Name $ISESteroidsPath

  if ($ISESteroidsOnDemand -eq $true) { 
    Write-Output -InputObject '[ISESteroids] Press CTRL + F12 to launch.'
    $psISE.CurrentPowerShellTab.AddOnsMenu.Submenus.Add('Launch ISESteroids','CTRL+F12',{Start-Steroids})
  }
  else {
    if (Get-Command -Name 'Start-Steroids' -ErrorAction SilentlyContinue -and ([System.Windows.Input.Keyboard]::IsKeyDown('Ctrl')) -eq $false) {
      Start-Steroids
      Start-Sleep -Milliseconds 523
    }
  }
}
#endregion ISESteroids

Set-Location -Path $PSUserOneDrive

If ($Verbose) { $VerbosePreference = $Verbose }             # Reset Verbose Output
If ($Error) { $Error | Get-ErrorInfo }                      # Output script errors