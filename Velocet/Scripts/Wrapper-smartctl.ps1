#requires -Version 3

<#
    Based on: http://stackoverflow.com/a/28570708/6813931/

    What SMART Stats Tell Us About Hard Drives:
    https://www.backblaze.com/blog/what-smart-stats-indicate-hard-drive-failures/
#>

function Get-SMART {
  <#
      .SYNOPSIS
      Get the S.M.A.R.T values for the given device (drive).

      .DESCRIPTION
      Get's the S.M.A.R.T values with the help of smartctl for the given device.

      Could be used in conjunction with Invoke-SMARTScan.

      .EXAMPLE
      Get-SMART /dev/sda | Format-Table
      Get the S.M.A.R.T values for /dev/sda as a nicely formatted table.

      .EXAMPLE
      Invoke-SMARTScan | % { Get-SMART -Device $_.Name} | ft
      >ID  Attribute               Flag   Value Worst Treshold Type     Updated Failing Now Raw         
      >--  ---------               ----   ----- ----- -------- ----     ------- ----------- ---         
      >1   Raw_Read_Error_Rate     0x002f 100   100   002      Pre-fail Always  -           0           
      >5   Reallocated_Sector_Ct   0x0033 100   100   010      Pre-fail Always  -           0
      
      Get's the S.M.A.R.T values for all devices and prints it as a nice table.

      .NOTES
      smartmontools (smartctl) needs to be installed and available via the PATH variable.
      smartmontools could obtained on Windows via Chocolatey (choco install smartmontools), from smartmontools.org or your preferred package manager on Linux/macOS.

      .LINK
      https://github.com/velocet/PowerShell/blob/master/Velocet/Scripts/Wrapper-smartctl.ps1

      .LINK
      https://smartmontools.org/
  #>
  
  param([Parameter(Mandatory,HelpMessage='Provide the device name (eg. /dev/sda)')][string]$Device)
  
  # Get the S.M.A.R.T values
  if ($env:OS -like 'Windows_NT') {
    $Drive = [string[]](& "$env:ProgramFiles\smartmontools\bin\smartctl.exe" -A $Device) | Select-Object -Skip 7
  } # Windows
  else {
    $Drive = [string[]](& smartctl -A $Device) | Select-Object -Skip 7
  } # Obscure other OS

  $result = @()
  foreach ($item in $Drive) {
    if ($item -Match '^\s*(\d+)\s+(\w+)\s+(\w+)\s+(\d+)\s+(\d+)\s+([\d-]+)\s+([\w-]+)\s+(\w+)\s+([\w-]+)\s+(\d+)') {
      $obj = [PSCustomObject]@{
        'ID'          = $matches[1]
        'Attribute'   = $matches[2]
        'Flag'        = $matches[3]
        'Value'       = $matches[4]
        'Worst'       = $matches[5]
        'Treshold'    = $matches[6]
        'Type'        = $matches[7]
        'Updated'     = $matches[8]
        'Failing Now' = $matches[9]
        'Raw'         = $matches[10]
      }
      $result += $obj
    }
  }
  return $result
}

function Invoke-ScanForDevices {
  <#
      .SYNOPSIS
      Get all devices known to smartctl.

      .DESCRIPTION
      Get's the name and type of the devices attached to the computer and available to smartctl from the smartmontools.

      .EXAMPLE
      Invoke-SMARTScan
      >Name     Type
      >----     ----
      >/dev/sda ata

      Outputs a list of all devices with their name and type.

      .EXAMPLE
      Invoke-SMARTScan | % { Get-SMART -Device $_.Name} | ft
      Get's the S.M.A.R.T values for all devices and prints it as a nice table.

      .NOTES
      smartmontools (smartctl) needs to be installed and available via the PATH variable.
      smartmontools could obtained on Windows via Chocolatey (choco install smartmontools), from smartmontools.org or your preferred package manager on Linux/macOS.

      .LINK
      https://github.com/velocet/PowerShell/blob/master/Velocet/Scripts/Wrapper-smartctl.ps1

      .LINK
      https://smartmontools.org/
  #>

  if ($env:OS -like 'Windows_NT') {
    $Scan = & "$env:ProgramFiles\smartmontools\bin\smartctl.exe" --scan
  } # Windows
  else {
    $Scan = & smartctl --scan
  } # Obscure other OS
  
  $Devices = @()
  foreach ($Device in $Scan) {
    $Device = $Device.Split()
    $obj = [PSCustomObject]@{
      'Name' = $Device[0]
      'Type' = $Device[2]
    }
    $Devices += $obj
  }
  $Devices
}
