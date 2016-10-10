PowerShell > 3
Get-CimInstance Win32_PnPEntity | where caption -match 'camera'.
Get-WmiObject Win32_PnPEntity | where {$_.caption -match 'webcam' -or $_.Caption -match 'camera'}
(Get-CimInstance Win32_PnPEntity | where caption -match 'cam').Caption
(Get-CimInstance Win32_PnPEntity | where caption -match 'cam').PNPDeviceID