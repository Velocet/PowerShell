#Requires -Version 5.0

<# ToDo

    ALLE WMI Abfragen in Threads auslagern und neue Data Collection selber erstellen
    WMI Querys am schnellsten oder soviel wie möglich einschränken!:
    #$query = 'Select * from Win32_OperatingSystem'
    #$query = [wmisearcher]$query
    #$query.Get()

    Sprache einbinden:
    Add-Type -AssemblyName System.Speech
    $say = New-Object -TypeName System.Speech.Synthesis.SpeechSynthesizer
    $say.Speak('Profil geladen')
#># ToDo
function Get-MOTD {
  <#
      .SYNOPSIS
      Displays system information.

      .DESCRIPTION
      A pretty "message of the day"-like script that prints some basic computer information to the console.

      .PARAMETER ComputerName
      Used for remote session. Specifies the name of the remote machine.

      .PARAMETER Credential
      Used in addition to -ComputerName. Specifies the credentials for the remote machine.
      a
      .NOTES
      Script-Name:          Get-MOTD.ps1
      Requires:             PowerShell 3.0

      Author:               Velocet, originally by Michal Millar (https://github.com/mmillar-bolis/ps-motd)
      Company:              -
      Version:              2.0.0-beta
      Release Date:         2016-09-20
      Purpose/Change:       Added multi-threading
      License:              BSD 3-Clause
      License-Link:         https://opensource.org/licenses/BSD-3-Clause
      Copyright:            2016, Velocet
      Copyright-Link:       https://github.com/velocet
      Notes:                -

      .LINK
      https://github.com/velocet/PowerShell/Velocet/Get-MOTD.ps1
      
      .EXAMPLE
      Get-MotD

  #> # Comment Based Help
  
  Param(
    [Parameter(Position=0)][ValidateNotNullOrEmpty()][string[]]$ComputerName,
    [Parameter(Position=1)][System.Management.Automation.Credential()][PsCredential][System.Management.Automation.CredentialAttribute()]$Credential
  )

  Begin {
    $StopWatch = [Diagnostics.Stopwatch]::StartNew()
    $StopWatch_ms = $StopWatch.ElapsedMilliseconds
    $StopWatch_ticks = $StopWatch.ElapsedTicks
    
    If (!$ComputerName) { $RemoteSession = $null }
    #$MaxThreads = $(Get-WmiObject -Class 'Win32_ComputerSystem' -Filter 'NumberOfLogicalProcessors != 0' -Property 'NumberOfLogicalProcessors').NumberOfLogicalProcessors
    $MaxThreads = 8
    $RunspacePool = [RunspaceFactory]::CreateRunspacePool(1,$MaxThreads)
    $RunspacePool.Open()
    $ScriptBlock1 = {
      $Operating_System = Get-CimInstance -ClassName 'Win32_OperatingSystem' -Namespace 'root\CIMV2'
      $Logical_Disk = Get-CimInstance -ClassName 'Win32_LogicalDisk'  -Namespace 'root\CIMV2' -Filter "DeviceID='$($Operating_System.SystemDrive)'"
      #$Network = Get-WmiObject -Class 'Win32_NetworkAdapter' -Namespace 'root\CIMV2' -Filter ('Speed <> NULL AND MacAddress <> NULL AND NOT Name LIKE "%Virtual%" AND NOT Name LIKE "%TAP%" AND NOT Name LIKE "%Bluetooth%"') -Property 'MACAddress','AdapterType','Name','Speed' | Select-Object 'MACAddress','AdapterType','Name',@{Name='Speed';Expression={$_.Speed/1000000}}
      $Network = & {
        $NetSh = netsh wlan show interface | Select -Skip 3 -First 17
        $NetSh = $NetSh.Replace(' : ', "`n").Trim().Split("`n")
        [PSCustomObject]@{Name = $NetSh[1];Description = $NetSh[3];GUID = $NetSh[5];MAC = $NetSh[7];State = $NetSh[9];SSIS = $NetSh[11];BSSID = $NetSh[13];NetworkType = $NetSh[15];RadioType = $NetSh[17];Authentification = $NetSh[19];Cipher = $NetSh[21];ConnectionMode = $NetSh[23];Channel = $NetSh[25];RateReceive = $NetSh[27];RateTransmit = $NetSh[29];Signal = $NetSh[31];Profile = $NetSh[33]}
      }
      [PSCustomObject]@{
        Operating_System = $Operating_System
        Processor = Get-CimInstance -ClassName Win32_Processor -Filter "DeviceID='CPU0'"
        Process_Count = (Get-Process).Count
        Shell_Info = "{0}.{1}" -f $PSVersionTable.PSVersion.Major,$PSVersionTable.PSVersion.Minor
        Logical_Disk = $Logical_Disk
        Network = $Network
      }
    } # Data Collection
    $ScriptBlock2 = {
      $IsAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] 'Admin')
      if($IsAdmin){
        $t = @(Get-WmiObject -Class MSAcpi_ThermalZoneTemperature -Namespace "root/wmi" -Filter "CurrentTemperature != 0")
        $returntemp = @()
        foreach ($temp in $t) {
          $currentTempCelsius = [math]::Round(($t.CurrentTemperature / 10) - 273.15,1)
          $returntemp += $currentTempCelsius.ToString() + "°C"  
        }
        return $returntemp
      }
      Else { return $false }
    } # CPU Temperatures
    $ScriptBlock3 = {
      $NetworkAdapter = Get-NetAdapter -Physical | where {$_.Status -eq 'Up'} | Get-NetIPAddress -AddressFamily IPv4 -PrefixOrigin Dhcp -SuffixOrigin Dhcp
      return $NetworkAdapter.IPv4Address
    } # Internal IPv4
    $ScriptBlock4 = { $Uri='http://diagnostic.opendns.com/myip'
      $WebClient=New-Object -TypeName 'Net.WebClient'
      $WebClient.DownloadString($Uri).ToString()
      $WebClient.Dispose()
    } # External IPv4
    $ScriptBlock5 = { Get-Date } # Get Date
    $ScriptBlock6 = { Get-Date -Format 'dddd, d. MMMM yyyy' } # Get Date Long
    $ScriptBlock7 = { 
      $WebClient=New-Object -TypeName 'Net.WebClient'
      $Uri='http://wertarbyte.de/gigaset-rss/?offensive=1&limit=140&cookies=1&lang=de&lang=en&format=rss&jar_id=47890485652059026906764953130202578209361565210116094'
      $FortuneCookie = [XML]($WebClient.DownloadString("$Uri"))
      $FortuneCookie.rss.channel.item.title
      $WebClient.Dispose()
    } # Fortune Cookie
  }

  Process {
    Try {
      If ($ComputerName) {
        If ("$ComputerName" -ne "$env:ComputerName") {
          $PSSessionParams = @{
            ComputerName = $ComputerName
            ErrorAction = 'Stop'
          } # Build Hash to be used for passing parameters to New-PSSession commandlet
          If ($Credential) { $PSSessionParams.Add('Credential', $Credential) } # Add optional parameters to hash
          Try { $RemoteSession = New-PSSession @PSSessionParams } # Create remote powershell session
          Catch { Throw $_.Exception.Message }
        }
        Else { $RemoteSession = $null }
      }    
      If ($RemoteSession) { $CommandParams.Add('Session',$RemoteSession) } # Add optional parameters to hash

      #region Jobs
      $Job1 = [powershell]::Create().AddScript($ScriptBlock1)
      $Job2 = [powershell]::Create().AddScript($ScriptBlock2)
      $Job3 = [powershell]::Create().AddScript($ScriptBlock3)
      $Job4 = [powershell]::Create().AddScript($ScriptBlock4)
      $Job5 = [powershell]::Create().AddScript($ScriptBlock5)
      $Job6 = [powershell]::Create().AddScript($ScriptBlock6)
      $Job7 = [powershell]::Create().AddScript($ScriptBlock7)
      
      $Job1.RunspacePool = $RunspacePool
      $Job1.RunspacePool = $RunspacePool
      $Job2.RunspacePool = $RunspacePool
      $Job3.RunspacePool = $RunspacePool
      $Job4.RunspacePool = $RunspacePool
      $Job5.RunspacePool = $RunspacePool
      $Job6.RunspacePool = $RunspacePool
      $Job7.RunspacePool = $RunspacePool

      $Jobs = @()
      $Jobs += New-Object PSObject -Property @{
        RunNum = 1
        Job = $Job1
        Result = $Job1.BeginInvoke()
      }
      $Jobs += New-Object PSObject -Property @{
        RunNum = 2
        Job = $Job2
        Result = $Job2.BeginInvoke()
      }
      $Jobs += New-Object PSObject -Property @{
        RunNum = 3
        Job = $Job3
        Result = $Job3.BeginInvoke()
      }
      $Jobs += New-Object PSObject -Property @{
        RunNum = 4
        Job = $Job4
        Result = $Job4.BeginInvoke()
      }
      $Jobs += New-Object PSObject -Property @{
        RunNum = 5
        Job = $Job5
        Result = $Job5.BeginInvoke()
      }
      $Jobs += New-Object PSObject -Property @{
        RunNum = 6
        Job = $Job6
        Result = $Job6.BeginInvoke()
      }
      $Jobs += New-Object PSObject -Property @{
        RunNum = 7
        Job = $Job7
        Result = $Job7.BeginInvoke()
      }

      $Results = @()
      ForEach ($Job in $Jobs) {
        $Results += $Job.Job.EndInvoke($Job.Result)
        $Job.Job.Dispose()
      }
      $RunspacePool.Dispose()
      #endregion

      #region Assign variables
      $ReturnedValues = $Results[0]
      $CPU_Temp = $Results[1]
      $IPint = $Results[2]
      $IPext = $Results[3]
      $Date = $Results[4]
      $Date_Long = $Results[5]
      $Fortune = $Results[6]
      $OS_Name = $ReturnedValues.Operating_System.Caption + ' (' + $ReturnedValues.Operating_System.Version + ')'
      $Computer_Name = $ReturnedValues.Operating_System.CSName
      $Network = $ReturnedValues.Network[0].Description -Replace '\(C\)','©' -Replace '\(R\)','®' -Replace '\(TM\)','™'
      $NetworkSpeed = $ReturnedValues.Network[0].RateReceive
      $NetworkSignal = $ReturnedValues.Network[0].Signal
      $Process_Count = $ReturnedValues.Process_Count
      $Uptime = "$(($Uptime = $Date - $($ReturnedValues.Operating_System.LastBootUpTime)).Days) Days, $($Uptime.Hours) Hours, $($Uptime.Minutes) Minutes"
      $Shell_Info = $ReturnedValues.Shell_Info
      $CPU_Info = $ReturnedValues.Processor.Name -replace '\(C\)', '©' -replace '\(R\)', '®' -replace '\(TM\)', '™' -replace 'CPU', '' -replace '\s+', ' '
      $CPU_Cores = "$($ReturnedValues.Processor.NumberOfCores) Cores/$($ReturnedValues.Processor.NumberOfLogicalProcessors) Threads"
      $Current_Load = "$($ReturnedValues.Processor.LoadPercentage) %"
      $Memory_Size_pct = ([Math]::round(($($ReturnedValues.Operating_System.TotalVisibleMemorySize-$ReturnedValues.Operating_System.FreePhysicalMemory)/$ReturnedValues.Operating_System.TotalVisibleMemorySize)*100))
      $Memory_Size = "{2} % ({0} GB/{1} GB)" -f ([Math]::Round($($ReturnedValues.Operating_System.TotalVisibleMemorySize-$ReturnedValues.Operating_System.FreePhysicalMemory)/1MB,1)),([Math]::Round($ReturnedValues.Operating_System.TotalVisibleMemorySize/1MB,1)),$Memory_Size_pct
      $Disk_Size_pct = [Math]::round(($($ReturnedValues.Logical_Disk.Size-$ReturnedValues.Logical_Disk.FreeSpace)/$ReturnedValues.Logical_Disk.Size)*100)
      $Disk_Size = "{2} % ({0} GB/{1} GB)" -f ([Math]::Round($($ReturnedValues.Logical_Disk.Size-$ReturnedValues.Logical_Disk.FreeSpace)/1GB)),([Math]::Round($ReturnedValues.Logical_Disk.Size/1GB)),$Disk_Size_pct
      #endregion

      #region Write to Console
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
      Write-Host -Object ("$Network @ $NetworkSpeed Mbit/s ($NetworkSignal)") -ForegroundColor Cyan
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
      Write-Host -Object $Fortune
      #Write-Verbose -Message "$(New-Object -TypeName System.String -ArgumentList @(' ',$($Console.WindowSize.Width - ([String]$StopWatch.ElapsedMilliseconds.ToString()).Length - 2)))$($StopWatch.ElapsedMilliseconds)ms"
      #endregion
    }    
    Catch {
      If ($RemoteSession) { Remove-PSSession -Id $RemoteSession }
      Throw $_.Exception.Message
    }
  }

  End { If ($RemoteSession) { Remove-PSSession -Id $RemoteSession } }
}