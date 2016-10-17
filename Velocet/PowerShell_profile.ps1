#Requires -Version 5

<#  # Variable                $PROFILE | fl -Force) // Specific: $PROFILE.CurrentUserCurrentHost)
    1 AllUsersAllHosts        $PsHome\profile.ps1
    2 AllUsersCurrentHost     $PsHome\Microsoft.PowerShell_profile.ps1
    3 CurrentUserAllHosts     [Environment]::GetFolderPath(“MyDocuments”)+'\WindowsPowerShell\profile.ps1'
    4 CurrentUserCurrentHost  [Environment]::GetFolderPath(“MyDocuments”)+'\WindowsPowerShell\Microsoft.PowerShell_profile.ps1'

    If corporate domain policies hijack your $HOME folder: Remove-Variable -Force HOME;Set-Variable HOME "C:\Users\$env:username"
#># Profiles and their start order

trap { Continue } # Handle errors: Pause but continue script execution

#region PSDefaultParameterValues
$PSDefaultParameterValues['Install-Module:SkipPublisherCheck']     = $true     # Skip Publisher Verification on Module Installation
$PSDefaultParameterValues['Install-Module:Scope']           = 'CurrentUser'     # Default modules installation path

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
$PSDefaultParameterValues['New-ModuleManifest:CompanyName'] = "$PSUserName PowerShell"
$PSDefaultParameterValues['New-ModuleManifest:Copyright']   = '{0:yyyy}' -f (Get-Date)
#endregion PSDefaultParameterValues

#region Console
$Host.DebuggerEnabled      = $false

[Console]::ForegroundColor = $ForegroundColor
[Console]::BackgroundColor = $BackgroundColor
[Console]::CursorSize      = 100
[Console]::WindowHeight    = [Math]::Floor($Host.UI.RawUI.MaxPhysicalWindowSize.Height/1.5)
[Console]::WindowWidth     = [Math]::Floor($Host.UI.RawUI.MaxPhysicalWindowSize.Width/1.5)
[Console]::BufferHeight    = 3000
[Console]::BufferWidth     = [Console]::WindowWidth

$Colors                         = $Host.PrivateData
$Colors.VerboseForegroundColor  = 'DarkCyan'
$Colors.VerboseBackgroundColor  = $BackgroundColor
$Colors.WarningForegroundColor  = 'Yellow'
$Colors.WarningBackgroundColor  = $BackgroundColor
$Colors.ErrorForegroundColor    = 'Red'
$Colors.ErrorBackgroundColor    = $BackgroundColor
$Colors.DebugForegroundColor    = 'Magenta'
$Colors.DebugBackgroundColor    = $BackgroundColor
$Colors.ProgressForegroundColor = $ForegroundColor
$Colors.ProgressBackgroundColor = 'DarkMagenta'
#endregion Console
#endregion Variables


#region Prompt
#funktion einbauen die in der titlebar anzeigt ob man admin ist
$Script:FirstRun = $true
function prompt { # Available characters: https://en.wikipedia.org/wiki/Code_page_850
  # WindowWith berechnung in eigene unterfunktion auslagern
  trap { Write-Warning -Message $_;
    #Write-Warning -Message $_.InvocationInfo.ScriptName
    #Write-Warning -Message $_.InvocationInfo.Line
    Write-Warning -Message $_.InvocationInfo.PositionMessage
    Continue
  } # Handle errors, suppress excption messages and continue
  function Draw-Titlebar { # Prepare Titlebar
    $Script:CurrentWindowWidth = $Host.UI.RawUI.WindowSize.Width # Get actual width for comparsion everytime prompt is called
    if($FirstRun) { # Execute only on first start
      Write-Verbose -Message '[PROMPT] FirstRun'
      $Script:FirstRun = $false
      $Script:Changed = $true
      $Script:TempPwd = $HOME
      $Script:ComputerName = $env:COMPUTERNAME
      $Script:DateLong = $(Get-Date -Format 'ddd, M. MMM. yyy')
      $Script:MaxWindowSize = $($Host.UI.RawUI.MaxPhysicalWindowSize.Width-2)
      $Script:WindowWidth = $Host.UI.RawUI.MaxPhysicalWindowSize.Width
      $Script:TitleStart = "🌐\\$ComputerName\$PSUserName\🏠".ToLower()
      $Script:TitleStartLength = $($TitleStart.Length)
      $Script:TitleMiddle = "⏪ $(Get-Date -Format 'H:mm') Uhr @ $DateLong ⏩"
      $Script:TitleMiddleLength = $($TitleMiddle.Length)
      $Script:TitleEnd = '¯\_(ツ)_/¯'
      $Script:TitleEndLength = $($TitleEnd.Length)
      $Script:TitleHalfLength = [Math]::Floor($($WindowWidth-$TitleMiddleLength)/2) # Get length before and after middle term
      $Script:LeftLength = $($TitleHalfLength-$TitleStartLength)          # Subtract $TitleStart length from $TitlebarLength/2
      $Script:LeftFill = $(New-Object -TypeName System.String -ArgumentList @(' ',$LeftLength))   # Fill left gap with spaces
      $Script:RightLength = $TitleHalfLength-$TitleEndLength              # Subtract $TitleEnd length from $TitlebarLength/2
      $Script:RightFill = $(New-Object -TypeName System.String -ArgumentList @(' ',$RightLength)) # Fill right gap with spaces
      $Script:HrWidth = [Math]::Floor($($CurrentWindowWidth)/3)
      $Script:Hr = $(New-Object -TypeName System.String -ArgumentList @(' ',$HrWidth)) + $(New-Object -TypeName System.String -ArgumentList @('═',$HrWidth))
    } # Execute on first run
    if($WindowWidth -ne $CurrentWindowWidth) { # Redraw only if window size changed (faster...)
      Write-Verbose -Message '[PROMPT] WindowWidth'
      $Script:WindowWidth = $CurrentWindowWidth
      if($WindowWidth -cge $MaxWindowSize) {
        $Script:WindowWidth = $MaxWindowSize-16
      } # Window width greater/equal max window width
      else {
        $Script:WindowWidth = $WindowWidth+$([Math]::Floor(($WindowWidth / 666 * 99)))
        if($WindowWidth -cge $MaxWindowSize){
          $Script:WindowWidth = $MaxWindowSize-16 # Set to $MaxWindowSize if higher than $MaxWindowSize
        } # Window width greater/equal max window width
      } # Window width lesser max window width
      $Script:HrWidth = [Math]::Floor($($CurrentWindowWidth)/3)
      $Script:Hr = $($(New-Object -TypeName 'System.String' -ArgumentList @(' ',$HrWidth))+$(New-Object -TypeName System.String -ArgumentList @('-',$HrWidth)))
      $Script:TitleHalfLength = [Math]::Floor($($WindowWidth-$TitleMiddleLength)/2) # Get length before and after middle term
      $Script:Changed = $true
    } # Recalculate $WindowWidth to center titlebar content and prompt content
    if($DateLong -ne $(Get-Date -Format 'ddd, M. MMM. yyy')) {
      Write-Verbose -Message '[PROMPT] Date'
      $Script:TempPWD = $false
      $Script:DateLong = $(Get-Date -Format 'ddd, M. MMM. yyy')
      $Script:TitleMiddle = "⏪ $(Get-Date -Format 'H:mm') - $DateLong ⏩"
      $Script:TitleMiddleLength = $TitleMiddle.Length
      $Script:TitleHalfLength = [Math]::Floor($($WindowWidth-$TitleMiddleLength)/2) # Get length before and after middle term
      $Script:Changed = $true
    } # Recalculate middle
    if($TempPWD -ne $PWD) { # VZ hat sich geändert
      Write-Verbose -Message '[PROMPT] PWD'
      $Script:TempPWD = $PWD
      #$Script:TempPWD = $($PWD.Path.Replace('git:\','🔀')) # Git replacement for titlebar
      $Script:TitleStart = "🌐\\$Computername\$PSUserName$($(Split-Path -NoQualifier -Path $PWD).Replace($(Split-Path -NoQualifier -Path $HOME),'\🏠'))".ToLower()
      $Script:TitleStartLength = [int]$TitleStart.Length
      $Script:TitleHalfLength = [Math]::Floor($($WindowWidth-$TitleMiddleLength)/2) # Get length before and after middle term
      $Script:Changed = $true
    } # Recalculate left side
    if($Changed){
      Write-Verbose -Message '[PROMPT] Changed'
      $Script:Changed = $false
      $Script:LeftLength = $TitleHalfLength-$TitleStartLength          # Subtract $TitleStart length from $TitlebarLength/2
      if([math]::sign($LeftLength) -lt 0){$Script:LeftLength = 5}
      $Script:LeftFill = $(New-Object -TypeName System.String -ArgumentList @(' ',$LeftLength))   # Fill left gap with spaces
      $Script:RightLength = $TitleHalfLength-$TitleEndLength            # Subtract $TitleEnd length from $TitlebarLength/2
      $Script:RightFill = $(New-Object -TypeName System.String -ArgumentList @(' ',$RightLength)) # Fill right gap with spaces
      #Abfrage wenn gesamtlänge der ersten beiden (also pwd + uhr) zu groß, dann abstand verkleiner bis auf 5, ansonsten rausschieben lassen
      $Script:WindowWidth = $CurrentWindowWidth # Reset $WindowWith
    } # Recalculate rest
    Write-Verbose -Message '[PROMPT] Draw'
    $Script:TitleMiddle = "⏪ $(Get-Date -Format 'H:mm') - $DateLong ⏩" # MUSS IMMER AUSGEFÜHRT WERDEN!
    $Host.ui.rawui.WindowTitle = "$TitleStart$LeftFill$TitleMiddle$RightFill$TitleEnd"
  } # Draw Titlebar
  Draw-Titlebar

  #region Draw Prompt
  # Horizontal Line Separator
  Write-Host "$Hr" -ForegroundColor DarkBlue
  # Time
  Write-Host '[' -ForegroundColor DarkGray -NoNewline
  Write-Host $(Get-Date -Format 'HH:mm') -ForegroundColor DarkCyan -NoNewline
  Write-Host ']' -ForegroundColor DarkGray -NoNewline
  # Path
  if ((Get-Command 'Get-GitDirectory' -ErrorAction SilentlyContinue)) {
    $realLASTEXITCODE=$LASTEXITCODE
    Write-VcsStatus
    $global:LASTEXITCODE=$realLASTEXITCODE
  } # Git Status 🔀
  Write-Host " $($PWD.Path.Replace($HOME,'~').Replace('\','/')) " -ForegroundColor green -NoNewline
  Write-Host $(if ($NestedPromptLevel -ge 1) { '>>' }) -NoNewline
  if (Test-Admin) {
    Write-Host '►' -ForegroundColor Red -NoNewline
  } # Administrator
  else {
    Write-Host '»' -ForegroundColor White -NoNewline
  } # Normal User
  return ' '
  #endregion Draw Prompt
}
#endregion Prompt

Set-Location -Path $PSUserOneDrive
Clear-Host
#Get-MOTD