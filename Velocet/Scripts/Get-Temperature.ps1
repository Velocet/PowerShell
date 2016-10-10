function Get-Temperature
{
  $Sensors = @((Get-WmiObject -Computer '.' -Class MSAcpi_ThermalZoneTemperature -Namespace 'root/wmi' -Filter 'CurrentTemperature != 0').CurrentTemperature)
  
  $ReturnTemp = @()
    
  foreach ($null in $Sensors)
  {
    $CurrentTemp = [Math]::Round(($($Sensors)/10)-273.15,1)
    $ReturnTemp += $CurrentTemp.ToString()+'°C'  
  }

  return $ReturnTemp

} # Get CPU temperature(s)
