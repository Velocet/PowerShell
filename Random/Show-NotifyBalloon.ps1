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