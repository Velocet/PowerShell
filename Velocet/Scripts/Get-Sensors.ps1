function Get-Sensors
{
  <#
      .SYNOPSIS
      Get information from all sensors.

      .DESCRIPTION
      Reads out all sensors from 'Win32_PerfFormattedData_Counters_ThermalZoneInformation'.

      .LINK
      https://GitHub.com/Velocet/PowerShell
  #>
  
  $Sensors = Get-WmiObject -ComputerName '.' -Namespace 'root\cimv2' -Class Win32_PerfFormattedData_Counters_ThermalZoneInformation

  $Sensors.Name
  $Sensors.Temperature

} # Get sensor information