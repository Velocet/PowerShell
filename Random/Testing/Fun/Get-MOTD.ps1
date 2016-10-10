#Requires -Version 5.0
Set-StrictMode -Version Latest
function Get-MotD {

  <#
      .SYNOPSIS
      Displays system information to a host.

      .DESCRIPTION
      A pretty "message of the day"-like script that prints some basic computer information to the console, as well as a colored logo.

      .NOTES
      Additional information about the function or script.
      Name:           Get-MotD
      Author:         Velocet, originally by Michal Millar (The Bolis Group, https://github.com/mmillar-bolis/ps-motd)
      Version:        1.0
      Release Date:   DATE
      Purpose/Change: Initial version
      License:        BSD 3-Clause
      License-Link:   https://github.com/mmillar-bolis/ps-motd/blob/master/LICENSE.md
      Copyright (c):  Velocet, The Bolis Group

      .LINK

      .EXAMPLE
      Get-MOTD
  #>

  Param(
    [Parameter(Position=0)][ValidateNotNullOrEmpty()][string[]]$ComputerName,
    [Parameter(Position=1)][System.Management.Automation.Credential()][PsCredential][System.Management.Automation.CredentialAttribute()]$Credential
  )

  Begin {
    If(-Not $ComputerName) { $RemoteSession = $null }
    $ScriptBlock = {
      $Operating_System = Get-CimInstance -ClassName 'Win32_OperatingSystem' -Namespace 'root\CIMV2'
      $Logical_Disk = Get-CimInstance -ClassName 'Win32_LogicalDisk'  -Namespace 'root\CIMV2' -Filter "DeviceID='$($Operating_System.SystemDrive)'"
      $Network = Get-WmiObject -Class 'Win32_NetworkAdapter' -Namespace 'root\CIMV2' -Filter ('Speed <> NULL AND MacAddress <> NULL AND NOT Name LIKE "%Virtual%" AND NOT Name LIKE "%TAP%"') -Property 'MACAddress','AdapterType','Name','Speed' | Select-Object 'MACAddress','AdapterType','Name',@{Name='Speed';Expression={$_.Speed/1000000}}      
      [pscustomobject]@{
        Operating_System = $Operating_System
        Processor = Get-CimInstance -ClassName Win32_Processor -Filter "DeviceID='CPU0'"
        Process_Count = (Get-Process).Count
        Shell_Info = "{0}.{1}" -f $PSVersionTable.PSVersion.Major,$PSVersionTable.PSVersion.Minor
        Logical_Disk = $Logical_Disk
        Network = $Network
      }
    } #Define ScriptBlock for data collection
  }

  Process {
    If ($ComputerName) {
      If ("$ComputerName" -ne "$env:ComputerName") {
        # Build Hash to be used for passing parameters to 
        # New-PSSession commandlet
        $PSSessionParams = @{
          ComputerName = $ComputerName
          ErrorAction = 'Stop'
        }

        # Add optional parameters to hash
        If ($Credential) {
          $PSSessionParams.Add('Credential', $Credential)
        }

        # Create remote powershell session   
        Try {
          $RemoteSession = New-PSSession @PSSessionParams
        }
        Catch {
          Throw $_.Exception.Message
        }
      } Else { 
        $RemoteSession = $null
      }
    }
        
    # Build Hash to be used for passing parameters to 
    # Invoke-Command commandlet
    $CommandParams = @{
      ScriptBlock = $ScriptBlock
      ErrorAction = 'Stop'
    }
        
    # Add optional parameters to hash
    if ($RemoteSession) {
      $CommandParams.Add('Session',$RemoteSession)
    }
               
    # Run ScriptBlock    
    try {
      $ReturnedValues = Invoke-Command @CommandParams
    }
    catch {
      if ($RemoteSession) {
        Remove-PSSession -Id $RemoteSession
      }
      throw $_.Exception.Message
    }

    function Test-Admin {
      ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] 'Admin')
    }

    if(Test-Admin){
      function Get-Temperature {
        $t = @(Get-WmiObject -Class MSAcpi_ThermalZoneTemperature -Namespace "root/wmi" -Filter "CurrentTemperature != 0")
        $returntemp = @()

        foreach ($temp in $t)
        {
          $currentTempCelsius = [math]::Round(($t.CurrentTemperature / 10) - 273.15,1)
          $returntemp += $currentTempCelsius.ToString() + "°C"  
        }
        return $returntemp    
      } # Get CPU core temperatures
    }
    
    function Get-InternalIPv4 {
      $IPs = [net.dns]::GetHostAddresses("") | Select-Object -ExpandProperty IP*
  
      foreach($IP in $IPs) {
        if(!($IP.EndsWith(".1")) -and !($IP.EndsWith("::1"))) {
          Return [string]$IP
        } # Strip all IPv6 Localhost and Router/Gateways ending on ".1" (eg. when using Hyper-V/VMWare/VirtualBox)
      }
    } # Get internal IP  

    # Assign variables
    $Date = Get-Date
    $Date_Long = Get-Date -Format "dddd, d. MMMM yyyy"
    $OS_Name = $ReturnedValues.Operating_System.Caption + ' (' + $ReturnedValues.Operating_System.Version + ')'
    $Computer_Name = $ReturnedValues.Operating_System.CSName
    $IPint = Get-InternalIPv4
    $IPext = [string]$(Invoke-RestMethod -Uri 'http://ipinfo.io/json' -TimeoutSec 1 | Select-Object -ExpandProperty ip)
    $Network = $ReturnedValues.Network[0].Name -Replace '\(C\)','©' -Replace '\(R\)','®' -Replace '\(TM\)','™'
    $NetworkSpeed = $ReturnedValues.Network[0].Speed
    $Process_Count = $ReturnedValues.Process_Count
    $Uptime = "$(($Uptime = $Date - $($ReturnedValues.Operating_System.LastBootUpTime)).Days) Days, $($Uptime.Hours) Hours, $($Uptime.Minutes) Minutes"
    $Shell_Info = $ReturnedValues.Shell_Info
    $CPU_Info = $ReturnedValues.Processor.Name -replace '\(C\)', '©' -replace '\(R\)', '®' -replace '\(TM\)', '™' -replace 'CPU', '' -replace '\s+', ' '
    $CPU_Cores = "$($ReturnedValues.Processor.NumberOfCores) Cores/$($ReturnedValues.Processor.NumberOfLogicalProcessors) Threads"
    $CPU_Temp = Get-Temperature
    $Current_Load = "$($ReturnedValues.Processor.LoadPercentage) %"
    $Memory_Size_pct = ([math]::round(($($ReturnedValues.Operating_System.TotalVisibleMemorySize-$ReturnedValues.Operating_System.FreePhysicalMemory)/$ReturnedValues.Operating_System.TotalVisibleMemorySize)*100))
    $Memory_Size = "{2} % ({0} MB/{1} MB)" -f ([math]::round($($ReturnedValues.Operating_System.TotalVisibleMemorySize-$ReturnedValues.Operating_System.FreePhysicalMemory)/1KB)),([math]::round($ReturnedValues.Operating_System.TotalVisibleMemorySize/1KB)),$Memory_Size_pct
    $Disk_Size_pct = [math]::round(($($ReturnedValues.Logical_Disk.Size-$ReturnedValues.Logical_Disk.FreeSpace)/$ReturnedValues.Logical_Disk.Size)*100)
    $Disk_Size = "{2} % ({0} GB/{1} GB)" -f ([math]::round($($ReturnedValues.Logical_Disk.Size-$ReturnedValues.Logical_Disk.FreeSpace)/1GB)),([math]::round($ReturnedValues.Logical_Disk.Size/1GB)),$Disk_Size_pct

    # Write to the Console
    #Write-Host -Object ("")
    #Write-Host -Object ("")
    Write-Host -Object ("         ,.=:^!^!t3Z3z.,                  ") -ForegroundColor Red
    Write-Host -Object ("        :tt:::tt333EE3                    ") -ForegroundColor Red
    Write-Host -Object ("        Et:::ztt33EEE ") -NoNewline -ForegroundColor Red
    Write-Host -Object (" @Ee.,      ..,     ") -ForegroundColor Green -NoNewline
    Write-Host $Date_Long -ForegroundColor DarkYellow
    Write-Host -Object ("       ;tt:::tt333EE7") -NoNewline -ForegroundColor Red
    Write-Host -Object (" ;EEEEEEttttt33#     ") -ForegroundColor Green
    Write-Host -Object ("      :Et:::zt333EEQ.") -NoNewline -ForegroundColor Red
    Write-Host -Object (" SEEEEEttttt33QL     ") -NoNewline -ForegroundColor Green
    Write-Host -Object ("User: ") -NoNewline -ForegroundColor Red
    Write-Host -Object ("$env:UserName") -ForegroundColor Cyan
    Write-Host -Object ("      it::::tt333EEF") -NoNewline -ForegroundColor Red
    Write-Host -Object (" @EEEEEEttttt33F      ") -NoNewline -ForeGroundColor Green
    Write-Host -Object ("Hostname: ") -NoNewline -ForegroundColor Red
    Write-Host -Object ("$Computer_Name @ $IPint") -ForegroundColor Cyan
    Write-Host -Object ("     ;3=*^``````'*4EEV") -NoNewline -ForegroundColor Red
    Write-Host -Object (" :EEEEEEttttt33@.      ") -NoNewline -ForegroundColor Green
    Write-Host -Object ("OS: ") -NoNewline -ForegroundColor Red
    Write-Host -Object ("$OS_Name") -ForegroundColor Cyan
    Write-Host -Object ("     ,.=::::it=., ") -NoNewline -ForegroundColor Cyan
    Write-Host -Object ("``") -NoNewline -ForegroundColor Red
    Write-Host -Object (" @EEEEEEtttz33QF       ") -NoNewline -ForegroundColor Green
    Write-Host -Object ("Network: ") -NoNewline -ForegroundColor Red
    Write-Host -Object ("$Network @ $NetworkSpeed MBit/s") -ForegroundColor Cyan
    Write-Host -Object ("    ;::::::::zt33) ") -NoNewline -ForegroundColor Cyan
    Write-Host -Object ("  '4EEEtttji3P*        ") -NoNewline -ForegroundColor Green
    Write-Host -Object ("Uptime: ") -NoNewline -ForegroundColor Red
    Write-Host -Object ("$Uptime") -ForegroundColor Cyan
    Write-Host -Object ("   :t::::::::tt33.") -NoNewline -ForegroundColor Cyan
    Write-Host -Object (":Z3z.. ") -NoNewline -ForegroundColor Yellow
    Write-Host -Object (" ````") -NoNewline -ForegroundColor Green
    Write-Host -Object (" ,..g.        ") -NoNewline -ForegroundColor Yellow
    Write-Host -Object ("Shell: ") -NoNewline -ForegroundColor Red
    Write-Host -Object ("Powershell $Shell_Info") -ForegroundColor Cyan
    Write-Host -Object ("   i::::::::zt33F") -NoNewline -ForegroundColor Cyan
    Write-Host -Object (" AEEEtttt::::ztF         ") -NoNewline -ForegroundColor Yellow
    Write-Host -Object ("CPU: ") -NoNewline -ForegroundColor Red
    Write-Host -Object ("$CPU_Info ($($CPU_Cores))") -ForegroundColor Cyan
    Write-Host -Object ("  ;:::::::::t33V") -NoNewline -ForegroundColor Cyan
    Write-Host -Object (" ;EEEttttt::::t3          ") -NoNewline -ForegroundColor Yellow
    Write-Host -Object ("Processes: ") -NoNewline -ForegroundColor Red
    Write-Host -Object ("$Process_Count") -ForegroundColor Cyan
    Write-Host -Object ("  E::::::::zt33L") -NoNewline -ForegroundColor Cyan
    Write-Host -Object (" @EEEtttt::::z3F          ") -NoNewline -ForegroundColor Yellow
    Write-Host -Object ("Current Load: ") -NoNewline -ForegroundColor Red
    Write-Host -Object ("$Current_Load $(if($CPU_Temp){"@ $CPU_Temp"})") -NoNewline -ForegroundColor Cyan
    Write-Host -Object ("") -ForegroundColor Cyan
    Write-Host -Object (" {3=*^``````'*4E3)") -NoNewline -ForegroundColor Cyan
    Write-Host -Object (" ;EEEtttt:::::tZ``          ") -NoNewline -ForegroundColor Yellow
    Write-Host -Object ("Memory: ") -NoNewline -ForegroundColor Red
    Write-Host -Object ("$Memory_Size") -ForegroundColor Cyan
    Write-Host -Object ("             ``") -NoNewline -ForegroundColor Cyan
    Write-Host -Object (" :EEEEtttt::::z7            ") -NoNewline -ForegroundColor Yellow
    Write-Host -Object ("System Volume: ") -NoNewline -ForegroundColor Red
    Write-Host -Object ("$Disk_Size") -ForegroundColor Cyan
    Write-Host -Object ("                 'VEzjt:;;z>*``            ") -ForegroundColor Yellow -NoNewline
    Write-Host -Object ("External IP: ") -NoNewline -ForegroundColor Red
    Write-Host -Object ("$IPext") -ForegroundColor Cyan
    Write-Host -Object ("                      ````                  ") -ForegroundColor Yellow
    #Write-Host -Object ("")
  }

  End {
    If ($RemoteSession) {
      Remove-PSSession -Id $RemoteSession
    }
  }
}