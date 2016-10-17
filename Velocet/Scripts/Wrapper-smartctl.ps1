#!/usr/bin/env powershell
<#PSScriptInfo
    .TITLE smartctl-Wrapper
    .VERSION 1.1.0
    .GUID 0ab53c0d-988a-4e5e-aa37-6b3c021b4a7b
    .AUTHOR Felix Niederhausen (Velocet [GitHub]), Mark Kraus (markekraus [GitHub])
    .COMPANYNAME
    .COPYRIGHT Â© 2016 Felix Niederhausen, Icon by Iconic [useiconic.com]
    .TAGS smartctl smart wrapper S.M.A.R.T
    .LICENSEURI https://github.com/Velocet/PowerShell/blob/master/LICENSE
    .PROJECTURI https://github.com/Velocet/PowerShell/
    .ICONURI https://github.com/Velocet/PowerShell/raw/master/Velocet/Scripts/Wrapper-smartctl.png
    .EXTERNALMODULEDEPENDENCIES
    .REQUIREDSCRIPTS
    .EXTERNALSCRIPTDEPENDENCIES
    .RELEASENOTES
    1.1.0 [2016-10-16] Merged pull request (thx Mark!)
    1.0.0 [2016-10-10] Initial publication to reddit/r/powershell
    Based on: http://stackoverflow.com/a/28570708/6813931/
#>
#requires -Version 3

function Get-SMART {
  <#
      .SYNOPSIS
      Get the S.M.A.R.T values for the given device (eg. HDD, SSD, etc.).
      .DESCRIPTION
      Outputs the S.M.A.R.T values with the help of smartctl for the given device. For further information refer to the smartmontools homepage.
      Could and should be used in conjunction with Invoke-SMARTScan.
      .PARAMETER DeviceName
      Specifies the name of the device to query.
      .EXAMPLE
      Get-SMART /dev/sda | Format-Table
      Output the S.M.A.R.T values for /dev/sda as a nicely formatted table.
      .EXAMPLE
      Invoke-SMARTScan | Get-SMART | ft
      >DeviceName   ID  Attribute               Flag   Value Worst Treshold Type     Updated Failing Now Raw
      >----------   --  ---------               ----   ----- ----- -------- ----     ------- ----------- ---
      >/dev/sda     1   Raw_Read_Error_Rate     0x000f 166   166   006      Pre-fail Always  -           0
      >/dev/sda     5   Reallocated_Sector_Ct   0x0032 253   100   036      Old_age  Always  -           0
      >...

      Output the S.M.A.R.T values for all devices and prints it as a nice table.
      .INPUTS
      String
      .OUTPUTS
      PSObject
      .NOTES
      smartmontools (smartctl) needs to be installed in the standard path ($env:ProgramFiles) under Windows.
      smartmontools could be obtained via Chocolatey (choco install smartmontools) on Windows, from smartmontools.org or your preferred package manager on Linux/macOS.

      Values that should be monitored if looking for failing HDDs (does not apply to SSDs) are:

      ID  Attribute
      --- ---------
      5 Reallocated Sectors Count
      187 Reported Uncorrectable Errors
      188 Command Timeout
      197 Current Pending Sector Count
      198 Uncorrectable Sector Count
      .LINK
      https://github.com/velocet/PowerShell/blob/master/Velocet/Scripts/Wrapper-smartctl.ps1
      .LINK
      https://smartmontools.org/
      .COMPONENT
      smartctl
  #>
  [OutputType([PSObject])]
  param
  (
    [Parameter(
        Mandatory,
        ValueFromPipeline,
        ValueFromPipelineByPropertyName,
        HelpMessage='Device Name (eg. /dev/sda)'
    )]
    [ValidateNotNullOrEmpty()]
    [Alias('Device','dev')]
    [string[]]$DeviceName
  )

  process {
    foreach ($Device in $DeviceName) {

      # Get the S.M.A.R.T values
      try {
        if ($env:OS -like 'Windows_NT') {
          $Drive = [string[]](& "$env:ProgramFiles\smartmontools\bin\smartctl.exe" -A $Device) | Select-Object -Skip 7
        } # Windows
        else {
          $Drive = [string[]](& smartctl -A $Device) | Select-Object -Skip 7
        } # Obscure other OS
      }
      catch [Management.Automation.CommandNotFoundException] {
        Write-Error -Message 'Smartmontools not installed in the default directory!'
        Write-Error -Message 'Install smartmontools from https://smartmontools.org/ or create a symbolic link if smartmontools is not installed in the default directory:'
        Write-Error -Message 'PS> New-Item -ItemType SymbolicLink -Name "$env:ProgramFiles\smartmontools" -Target "PATH\TO\SMARTMONTOOLS"'
      } # Catch Windows Command Not Found Exception
      catch {
        Write-Error -Message 'Smartmontools not installed or not accessible!'
      } # Catch Linux/macOS Command Not Found Exception
      
      foreach ($item in $Drive) {
        if ($item -Match '^\s*(\d+)\s+(\w+)\s+(\w+)\s+(\d+)\s+(\d+)\s+([\d-]+)\s+([\w-]+)\s+(\w+)\s+([\w-]+)\s+(\d+)') {
          $obj = [PSCustomObject]@{
            'DeviceName'  = $DeviceName
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
          Write-Output -InputObject $obj
        } #End if
      } #End foreach Item
    } # End foreach Device
  } #End process
} #End function

function Invoke-SMARTScan {
  <#
      .SYNOPSIS
      Output all devices (drives) known to smartctl.
      .DESCRIPTION
      Output the name and type of the attached devices available to smartctl.
      .EXAMPLE
      Invoke-SMARTScan
      >DeviceName   DeviceType
      >----------   ----------
      >/dev/sda     ata
      >/dev/sdb     scsi
      >/dev/sdc     scsi
      >/dev/csmi0,0 ata
      Output a list of all devices with their name and type.
      .EXAMPLE
      Invoke-SMARTScan | Get-SMART | ft
      Output the S.M.A.R.T values for all devices and print it as a nice table.
      .INPUTS
      None. You cannot pipe objects to Invoke-SMARTScan.
      .OUTPUTS
      PSObject.
      .NOTES
      smartmontools (smartctl) needs to be installed in the standard path ($env:ProgramFiles) under Windows.
      smartmontools could obtained via Chocolatey (choco install smartmontools) on Windows, from smartmontools.org or your preferred package manager on Linux/macOS.
      .LINK
      https://github.com/velocet/PowerShell/blob/master/Velocet/Scripts/Wrapper-smartctl.ps1
      .LINK
      https://smartmontools.org/
      .COMPONENT
      smartctl
  #>

  try {
    if ($env:OS -like 'Windows_NT') {
      $Scan = & "$env:ProgramFiles\smartmontools\bin\smartctl.exe" --scan
    } # Windows
    else {
      $Scan = & smartctl --scan
    } # Obscure other OS
  }
  catch [Management.Automation.CommandNotFoundException] {
    Write-Error -Message 'Smartmontools not installed in the default directory!'
    Write-Error -Message 'Install smartmontools from https://smartmontools.org/ or create a symbolic link if smartmontools is not installed in the default directory:'
    Write-Error -Message 'PS> New-Item -ItemType SymbolicLink -Name "$env:ProgramFiles\smartmontools" -Target "PATH\TO\SMARTMONTOOLS"'
  } # Catch Windows Command Not Found Exception
  catch {
    Write-Error -Message 'Smartmontools not installed or not accessible!'
  } # Catch Linux/macOS Command Not Found Exception
  
  foreach ($Device in $Scan) {
    $Device = $Device.Split()
    $obj = [PSCustomObject]@{
      'DeviceName' = $Device[0]
      'DeviceType' = $Device[2]
    }
    Write-Output -InputObject $obj
  } # End foreach Device
}
