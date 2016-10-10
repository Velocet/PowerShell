# https://geekeefy.wordpress.com/2016/09/17/powershell-find-unsecurewificonnections-nearby/
Function Show-NotifyBalloon($Title, $Message)
{
    [system.Reflection.Assembly]::LoadWithPartialName('System.Windows.Forms') | Out-Null            
    $Global:Balloon = New-Object System.Windows.Forms.NotifyIcon            
    $Balloon.Icon = [System.Drawing.Icon]::ExtractAssociatedIcon((Get-Process -id $pid | Select-Object -ExpandProperty Path))                    
    $Balloon.BalloonTipIcon = 'Info'           
    $Balloon.BalloonTipText = $Message            
    $Balloon.BalloonTipTitle = $Title            
    $Balloon.Visible = $true            
    $Balloon.ShowBalloonTip(10000)
    Start-Sleep -Seconds 20
    $Balloon.Visible =$false; $Balloon.Dispose()
}

Function Find-UnsecureWIFIConnection
{

Param(

        [Switch] $LogWithTimestamp
)

    $data = (netsh wlan show networks mode=Bssid | ?{$_ -like "SSID*" -or $_ -like "*Authentication*" -or $_ -like "*Encryption*"}).trim()
    
    $result = For($i = 0;$i -lt $data.count;)
    {
        ''|Select @{n='Connection';e={($data[$i].split(':')[1]).trim()}}, @{n='Authentication';e={($data[$i+1].split(':')[1]).trim()}}, @{n='Encryption';e={($data[$i+2].split(':')[1]).trim()}}
        $i=$i+3
    }



    If($LogWithTimestamp)
    {
        $result | ?{$_.connection -ne '' -and $_.encryption -like "*none*"}|select *, @{n="TimeStamp";e={(Get-Date).ToString("HH:mm:ss dd-MMM-yyyy")}} | tee -Variable Result

    }
    else
    {
        $result | ?{$_.connection -ne '' -and $_.encryption -like "*none*"}| Tee -Variable Result
    }
    
    $result | Export-Csv -Path "$env:TEMP\UnsecureWiFi_Logs.csv" -NoTypeInformation -Append
}


$UnsecureConnections = Find-UnsecureWIFIConnection -LogWithTimestamp
$Message = $UnsecureConnections.connection | %{$_+[System.Environment]::NewLine}
$Title = "$($UnsecureConnections.connection.count) Unsecure Connections Found nearby"

Show-NotifyBalloon  $Title $Message