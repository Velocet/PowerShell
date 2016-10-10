#Multithreaded script benutzen
#TODO Transparenz setzen

$StopWatch = [diagnostics.stopwatch]::StartNew()
$StopWatch_ms = $StopWatch.ElapsedMilliseconds
$StopWatch_ticks = $StopWatch.ElapsedTicks
$Verbose = $VerbosePreference
$VerbosePreference = 'Continue'

Write-Verbose -Message '[PROFILE] Velocet: Loading...'

<#
    List Profiles: $PROFILE | Format-List -Force
    List specific Profile: $PROFILE.AllUsersAllHosts 

    # Host    User    Variable                        Path
    ___________________________________________________________________________________________________________________________________________________
    1 All     All     AllUsersAllHosts       $PsHome\profile.ps1
    2 Console All     AllUsersCurrentHost    $PsHome\Microsoft.PowerShell_profile.ps1
    3 All     Current CurrentUserAllHosts    [Environment]::GetFolderPath(“MyDocuments”)\WindowsPowerShell\profile.ps1
    4 Console Current CurrentUserCurrentHost [Environment]::GetFolderPath(“MyDocuments”)\WindowsPowerShell\Microsoft.PowerShell_profile.ps1
    2 ISE     All                            $PsHome\Microsoft.PowerShellISE_profile.ps1
    4 ISE     Current                        [Environment]::GetFolderPath(“MyDocuments”)\WindowsPowerShell\Microsoft.PowerShellISE_profile.ps1
#>

#region Variables

#             Variables: http://technet.microsoft.com/library/hh847734.aspx
#   Automatic Variables: http://technet.microsoft.com/library/dd347675.aspx
#  Preference Variables: http://technet.microsoft.com/library/hh847796.aspx
# Environment Variables: http://technet.microsoft.com/library/dd347713.aspx
#      Remote Variables: http://technet.microsoft.com/library/jj149005.aspx

#Get-Variable                                                       # List PowerShell Variables "$VARIABLE"
#Get-ChildItem Env:                                                 # List Local Environment Variables "$env:VARIABLE"
#[Environment+SpecialFolder]::GetNames([Environment+SpecialFolder]) # List Special Folders $([Environment]::GetFolderPath('SPECIALFOLDER'))

$profilePath = $(Split-Path -Path $profile)
$script:CurrentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
$script:pc_name = $($env:computername).ToLower()
$script:pc_user = $($env:USERNAME).ToLower()
$MaxWindowSize = $($Host.UI.RawUI.MaxPhysicalWindowSize.Width-2)

# Set up GIT:\ to point to the GIT root folder
$null = New-PSDrive -Name GIT -PSProvider FileSystem -Root "$([Environment]::GetFolderPath('MyDocuments'))\GitHub"

if(Test-Path -Path "$profilePath\Velocet") {
  # Get Known Folders via GUID. Usage:
  # [shell32]::GetKnownFolderPath([KnownFolder]::Downloads)
  . "$profilePath\Velocet\SHGetKnownFolderPath.ps1"
  . "$profilePath\Velocet\Get-ComputerInformation.ps1"
  . "$profilePath\Velocet\Get-MOTD.ps1"
  . "$profilePath\Velocet\Resize-ConsoleWindow.ps1"
  . "$profilePath\Velocet\Show-Image.ps1"
  Import-Module -Name "$profilePath\Velocet\Invoke-AsAdmin"
  Import-Module -Name "$profilePath\Velocet\PSSpeak"
  Import-Module -Name "$profilePath\Velocet\Write-Ascii"
}
#endregion Variables

#region Encoding

<# Commands to show UTF-8 support
    [System.Console]::InputEncoding
    [System.Console]::OutputEncoding
    [Console]::InputEncoding
    [Console]::OutputEncoding
    $OutputEncoding
    chcp # Show Active Codepage
#>

<# Uncomment for full UTF-8 support
    & "$env:windir\system32\chcp.com" 65001
    [Console]::OutputEncoding = New-Object -typename System.Text.UTF8Encoding
    $OutputEncoding = [Console]::OutputEncoding
    #[Console]::InputEncoding = New-Object -typename System.Text.UTF8Encoding
#>

#endregion

try {
  #region Aliases
  New-Alias -Name edit -Value "${env:ProgramFiles(x86)}\Notepad++\notepad++.exe"
  New-Alias -Name gh -Value Get-Help
  New-Alias -Name grep -Value Get-String
  New-Alias -Name fortune -Value Get-Fortune
  New-Alias -Name qs -Value Quote-String
  New-Alias -Name ql -Value Quote-List
  New-Alias -Name touch -Value New-File
  function subl { & "${env:ProgramFiles}\Sublime Text 3\sublime_text.exe" $args } # Sublime Editor
  function hosts { & "$env:windir\System32\notepad.exe" "$Env:windir\System32\drivers\etc\hosts" }
  function pro { & "$env:windir\System32\notepad.exe" $profile }
  Function VS {	Invoke-Item *.sln } # Launch VS for sln(s) in current folder
  Function e { Invoke-Item . } # Launch Explorer in current folder
  function Quote-String { "$args" } 
  function Quote-List { $args } 
  
  #region Filters
  # behave like a grep command but work on objects, used to be still be allowed to use grep
  filter match( $reg ) { if ($_.tostring() -match $reg) { $_ } }
  # behave like a grep -v command but work on objects
  filter exclude( $reg ) { if (-not ($_.tostring() -match $reg)) { $_ } }
  # behave like match but use only -like
  filter like( $glob ) { if ($_.toString() -like $glob) { $_ } }
  filter unlike( $glob ) { if (-not ($_.tostring() -like $glob)) { $_ } }
  #endregion Filters
  
  #region Push-Location
  function .. { Push-Location -Path ..}
  function ... { Push-Location -Path ..\..}
  function .... { Push-Location -Path ..\..\..}
  function ..... { Push-Location -Path ..\..\..\..}
  function ...... { Push-Location -Path ..\..\..\..\..}
  function ....... { Push-Location -Path ..\..\..\..\..\..}
  #endregion Push-Location
  #endregion Aliases

  #region Layout
  [Console]::ForegroundColor = 'White'
  [Console]::BackgroundColor = 'Black'

  $console = $host.UI.RawUI
  $console_width = [Math]::round(($host.UI.RawUI.MaxPhysicalWindowSize.Width / 1.5))
  $console_height = [Math]::round(($host.UI.RawUI.MaxPhysicalWindowSize.Height / 1.6))
  
  # Buffer Size
  $buffer = $console.BufferSize
  $buffer.Width = $console_width
  $buffer.Height = 3000
  $console.BufferSize = $buffer
  
  # Window Size
  $size = $console.WindowSize
  $size.Width = $console_width
  $size.Height = $console_height
  $console.WindowSize = $size
  
  $colors = $host.PrivateData
  $colors.VerboseForegroundColor = 'Black'
  $colors.VerboseBackgroundColor = 'Cyan'

  $colors.WarningForegroundColor = 'Black'
  $colors.WarningBackgroundColor = 'Yellow'
      
  $colors.ErrorForegroundColor = 'Black'
  $colors.ErrorBackgroundColor = 'Red'
      
  $colors.DebugForegroundColor = 'Black'
  $colors.DebugBackgroundColor = 'DarkMagenta'
      
  $colors.ProgressForegroundColor ='Red'
  $colors.ProgressBackgroundColor = 'White'
  #endregion Layout

  #region Functions
  function Test-Admin {
    ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] 'Admin')
  } # Test if Admin
  
  function New-File {
    $file = $args[0]
    if($args[0]) {
      if(Test-Path $file)
      {
        Write-Output 'File exists!'
      } # Check if file exists
      else {
        Write-Output $null > $file
      }
    } # Check if argument given
  } # touch

  function Get-ExternalIPv4 {
    [string]$IP = Invoke-RestMethod http://ipinfo.io/json -TimeoutSec 1 | Select-Object -ExpandProperty ip
  } # Get external IP

  function Get-InternalIPv4 {
    $IPs = [net.dns]::GetHostAddresses('') | Select-Object -ExpandProperty IP*  
    foreach($IP in $IPs) {
      if(!($IP.EndsWith('.1')) -and !($IP.EndsWith('::1'))) {
        Return [string]$IP
      } # Strip IPv6 Localhost and Router/Gateways ending on ".1" (eg. when using Hyper-V/VMWare/VirtualBox)
    }
  } # Get internal IP
  
  function Get-Fortune {
    $fortune = Invoke-WebRequest -Uri 'http://wertarbyte.de/gigaset-rss/?offensive=1&limit=140&cookies=1&lang=de&lang=en&format=rss&jar_id=47890485652059026906764953130202578209361565210116094' -TimeoutSec 1
    (([XML]$fortune.Content).rss.channel.item.title)
  } # Get Fortune Cookie
  
  function Get-String {
    Param($string)
    $input | Out-String -Stream | Select-String $string | Select-Object @{Name = '#'; Expression = {$_.LineNumber}},Line | Format-Table
  } # grep

  function Get-Temperature {
    $t = @( Get-WmiObject -Class MSAcpi_ThermalZoneTemperature -Namespace 'root/wmi' -Filter 'CurrentTemperature != 0')
    $returntemp = @()
    foreach ($null in $t) {
      $currentTempCelsius = [math]::Round(($t.CurrentTemperature / 10) - 273.15,1)
      $returntemp += $currentTempCelsius.ToString() + '°C'  
    }
    return $returntemp    
  } # Get CPU temperature(s)
  
  function Get-Sensors {
    Get-WmiObject -Class Win32_PerfFormattedData_Counters_ThermalZoneInformation | Select-Object Name,Temperature
  } # Get Sensor(s) information

  function Get-Syntax {    
    param([string]$cmdlet)
    get-command $cmdlet -syntax
  } # Get syntax of cmdlet
  
  function Remove-Line {
    param([string]$file)
    param([string]$string)
    Get-Content -Path $file | Where-Object {$_ -notmatch $string} | Set-Content -Path "$file.NEW"
    Rename-Item -Path $file -NewName "$file.BAK"
    Rename-Item -Path "$file.NEW" -NewName $file    
  } # Remove line and backup of file

  function Get-Excuse {
    $url = 'http://pages.cs.wisc.edu/~ballard/bofh/bofhserver.pl'
    $ProgressPreference = 'SilentlyContinue'
    $page = Invoke-WebRequest -Uri $url -UseBasicParsing
    $pattern = '(?m)<br><font size = "\+2">(.+)'
    if ($page.Content -match $pattern) {
      $matches[1]
    }
  } # BOFH excuses
  #endregion

  #region Prompt 
  Write-Verbose -Message '[PROFILE] Prompt: Loading...' 
  function prompt {
    #region Titlebar
    # Update $ActualWindowWidth after every new command
    $ActualWindowWidth = $Host.UI.RawUI.WindowSize.Width
    # Prepare Titlebar
    $TitleStart = "🌐\\$pc_name\$pc_user$($(Split-Path -NoQualifier $PWD).Replace($(Split-Path -NoQualifier $HOME),'\🏠').ToLower())"
    $TitleMiddle = "⏪ $(Get-Date -Format 'HH:mm') Uhr @ $(Get-Date -Format 'dddd, d. MMMM yyyy') ⏩"
    $TitleEnd = "¯\_(ツ)_/¯"
    Write-Verbose -Message "[PROFILE] Titlebar: $TitleStart $TitleMiddle $TitleEnd"
  
    # Execute only if window size has changed for faster redraw
    if($WindowWidth -eq $ActualWindowWidth) {
      Write-Verbose -Message '[PROFILE] Titlebar: Window Size changed' 
      # Update $WindowWith with new actual window width
      $WindowWidth = $ActualWindowWidth
      # Check if running maximized
      if($WindowWidth -eq $MaxWindowSize) {
        Write-Verbose -Message '[PROFILE] Titlebar: Window is maximized'
        # Substract by 16 chars cause this is the max window width when maximized
        $WindowWidth = $MaxWindowSize-16
      }
      else {
        Write-Verbose -Message '[PROFILE] Titlebar: Window not maximized'
        # Calculate maximum $WindowWidth relative to $WindowWidth
        # as there is no way to determine maximum width when running windowed
        $WindowWidth = $WindowWidth+$([Math]::Round(($WindowWidth / 666 * 100),0))
        # Check if $WindowWith now exceeds max physical window width
        if($WindowWidth -gt $MaxWindowSize){
          Write-Verbose -Message '[PROFILE] Titlebar: Window Size too big'
          # Set $WindowWith to max physical window size
          $WindowWidth = $MaxWindowSize
        } 
      } # Running in windowed mode
      # Calculate Titlebar
      $TitleLenght = $($TitleMiddle.Length)+$($TitleEnd.Length)+$($TitleStart.Length)
      $TitleWidth = [Math]::Round($($WindowWidth-$TitleLenght)/2)
      $TitleSpace = $(New-Object System.String @(' ',$TitleWidth))
      Write-Verbose -Message "[PROFILE] Titlebar: Calculated '$TitleLenght' '$TitleWidth' '$TitleSpace'"
      # Calculate Horizontal Line
      $hrWidth = [Math]::Round($($ActualWindowWidth)/3)
      $hrSpace = $(New-Object System.String @(' ',$hrWidth))
      $hr = $(New-Object System.String @('-',$hrWidth))      
      Write-Verbose -Message "[PROFILE] HR: Calculated '$hrWidth' '$hrSpace' '$hr'"
      $WindowWidth = $ActualWindowWidth # Reset $WindowWith
    } # Calculate window width to center content for the Titlebar and prompt
    
    # Draw Titlebar
    Write-Verbose -Message "[PROFILE] Titlebar: Drawing..."
    $host.ui.rawui.WindowTitle = "$TitleStart$TitleSpace$TitleMiddle$TitleSpace$TitleEnd"
    Write-Verbose -Message "[PROFILE] Titlebar: Drawed"
    #endregion Titlebar

    # Prompt
    Write-Verbose -Message "[PROFILE] Prompt: Drawing..."
    Write-Host "$hrSpace$hr" -ForegroundColor DarkBlue # Draw horizontal line
    # Time 
    Write-Host '[' -noNewLine -ForegroundColor DarkGray
    Write-Host $(Get-Date -Format 'HH:mm') -Foreground DarkCyan -noNewLine
    Write-Host '] ' -noNewLine -ForegroundColor DarkGray
    # Path
    Write-Host $($PWD.Path.Replace($HOME,'~').replace('\','/')) -foreground green -noNewLine
    Write-Host $(if ($nestedpromptlevel -ge 1) { '>>' }) -noNewLine    
    if (Test-Admin) {
      Write-Host ' >' -ForegroundColor Red -NoNewline
    } # Admin
    else{      
      Write-Host ' »' -ForegroundColor White -NoNewline
    } # Normal User
    Write-Verbose -Message "[PROFILE] Prompt: Drawed..."
    return ' '
  }
  #endregion Prompt
  Write-Verbose -Message '[PROFILE] Prompt: Loaded' 

  <#
      #region Transcript
      $profilePath = Split-Path $profile

      if(Test-Path $profilePath) {
      Try {
      #[io.file]::OpenWrite($outfile).close()
    
      $profilePath = $profilePath + '\Logs\'
    
      if(!(Test-Path $profilePath)) {
      New-Item -ItemType Directory -Path $profilePath
      } # Create 'Logs' folder inside $profilePath if not exists
    
      Start-Transcript -OutputDirectory $profilePath # Start a record of the PowerShell session in a text file  
      } # Check for Write Access
  
      Catch {
      Write-Error -Message "[ERROR] Can't set Start-Transcript!"
      }
      }
      #endregion Transcript
  #>
  
  Set-Location $HOME
  Pause
  Clear-Host
  Write-Host "$(New-Object System.String @(' ',$($Host.UI.RawUI.WindowSize.Width - $("$($StopWatch.ElapsedMilliseconds) ms").Length-2))) $($StopWatch.ElapsedMilliseconds) ms" -ForegroundColor DarkGray -NoNewline
  Get-MOTD
  Get-Fortune
}

catch {
  Write-Host 'Caught an exception!' -ForegroundColor Red
  Write-Host “Exception Type: $($_.Exception.GetType().FullName)” -ForegroundColor Red
  Write-Host “Exception Message: $($_.Exception.Message)” -ForegroundColor Red
}

finally {
  Write-Verbose -Message "[RUNTIME] $($($StopWatch.ElapsedTicks)-$StopWatch_ticks) ticks ($($($StopWatch.ElapsedMilliseconds)-$StopWatch_ms) ms)"
  $VerbosePreference = $Verbose
  $StopWatch.Stop()
}