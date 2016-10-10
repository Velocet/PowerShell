<#
    Usage:

    $ForegroundColor = [System.ConsoleColor]::Red
    $BackgroundColor = [System.ConsoleColor]::Black
    $array = @(
    "----------------------------------------",
    "|    ! Enviroment not initialied !     |",
    "|                                      |",
    "| ! Please run Initialize-Enviroment ! |",
    "----------------------------------------"
    )

    Write-DisplayWarning -ForegroundColor $ForegroundColor -BackgroundColor $BackgroundColor -array $array -Mode Blink
#>
function Write-DisplayWarning {
  Param (
    [ConsoleColor]$ForegroundColor=[ConsoleColor]::Red,
    [ConsoleColor]$BackgroundColor=[ConsoleColor]::Black,
    [array]$array,    
    [ValidateSet('Progress', 'ProgressBlink', 'Blink')][string]$Mode=$false
  )
  function Invoke-DisplayWarning {
    Param ([ConsoleColor]$ForegroundColor,[ConsoleColor]$BackgroundColor,[array]$array)    
    $Count=$array.Count
    $WindowHeightFree=[Math]::Floor(([Console]::WindowHeight-$Count)/2)
    [Console]::ForegroundColor=$ForegroundColor;[Console]::BackgroundColor=$BackgroundColor;[Console]::Clear()
    [String]::New("`n",$WindowHeightFree)
    for($i=0;$i -le $Count;$i++){
      $WindowsWidthFree=[Math]::Floor(([Console]::WindowWidth-$array[$i].Length)/2)
      Write-Host -Object ([String]::New(' ',$WindowsWidthFree)) -NoNewline -ForegroundColor $ForegroundColor -BackgroundColor $BackgroundColor
      Write-Host -Object $array[$i] -ForegroundColor $BackgroundColor -BackgroundColor $ForegroundColor
    } # Draw middle of the screen with the text from the array
    [String]::New("`n",$WindowHeightFree)
  }

  if ($Mode -eq 'Progress' -or $Mode -eq 'ProgressBlink' -or $Mode -eq 'Blink') {
    $CapsLock = New-Object -ComObject WScript.Shell
    if ($array[0]) {$Activity = $array[0].ToString()} else {$Activity = ' '}
    if ($array[1]) {$Status = $array[1].ToString()} else {$Status = ' '}
    if ($array[2]) {$CurrentOperation = $array[2].ToString()} else {$CurrentOperation = ' '}
  }
  
  if ($Mode -eq 'Blink') {
    while (!([console]::KeyAvailable)) {
      #$CapsLock.SendKeys('{CAPSLOCK}')
      Invoke-DisplayWarning -ForegroundColor $ForegroundColor -BackgroundColor $BackgroundColor -array $array
      Start-Sleep -Milliseconds 500
      #$CapsLock.SendKeys('{CAPSLOCK}')
      Invoke-DisplayWarning -ForegroundColor $BackgroundColor -BackgroundColor $ForegroundColor -array $array
      Start-Sleep -Milliseconds 500
    }
  }
  elseif ($Mode -eq 'Progress') {
    while (!([console]::KeyAvailable)) {
      $CapsLock.SendKeys('{CAPSLOCK}')
      Write-Progress -Activity $Activity -Status $Status -CurrentOperation $CurrentOperation
      Start-Sleep -Seconds 1
    }
  }
  elseif ($Mode -eq 'ProgressBlink') {
    while (!([console]::KeyAvailable)) {
      $CapsLock.SendKeys('{CAPSLOCK}')
      Write-Progress -Activity $Activity -Status $Status -CurrentOperation $CurrentOperation -Completed
      Start-Sleep -Milliseconds 500
      $CapsLock.SendKeys('{CAPSLOCK}')
      Write-Progress -Activity $Activity -Status $Status -CurrentOperation $CurrentOperation
      Start-Sleep -Milliseconds 1000
    }
  }
  else {
    Invoke-DisplayWarning -ForegroundColor $ForegroundColor -BackgroundColor $BackgroundColor -array $array
    Pause
  }
}
<#
$ForegroundColor = [ConsoleColor]::Red
$BackgroundColor = [ConsoleColor]::Black
$array = @(
  "----------------------------------------",
  "|    ! Enviroment not initialied !     |",
  "|                                      |",
  "| ! Please run Initialize-Enviroment ! |",
  "----------------------------------------"
)

Write-DisplayWarning -ForegroundColor $ForegroundColor -BackgroundColor $BackgroundColor -array $array -Mode Blink
#>