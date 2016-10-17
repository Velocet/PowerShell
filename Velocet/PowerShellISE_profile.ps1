
#http://community.idera.com/powershell/powertips/b/tips/posts/color-week-using-transparency-in-the-powershell-ise-console
#http://community.idera.com/powershell/powertips/b/tips/posts/color-week-using-clear-names-for-powershell-ise-colors
#    Farben für ISE: [System.Windows.Media.Colors]::Yellow.ToString()

<#  # Variable                Path
    1 AllUsersAllHosts        $PsHome\profile.ps1
    2 AllUsersCurrentHost     $PsHome\Microsoft.PowerShellISE_profile.ps1
    3 CurrentUserAllHosts     [Environment]::GetFolderPath(“MyDocuments”)\WindowsPowerShell\profile.ps1
    4 CurrentUserCurrentHost  [Environment]::GetFolderPath(“MyDocuments”)\WindowsPowerShell\Microsoft.PowerShellISE_profile.ps1
#> # PoShISE profiles and their start order: "$profile | fl -Force". ISE options: "$psISE.Options"

trap { Continue } # Handle errors: Pause but continue script execution

#region psISE
#TODO
#Thema Farbe: per XML datei theme setzen
$ISESteroidsOnLoad   = $true
$ISESteroidsOnDemand = $false

$psISE.Options.Zoom = 100
#endregion

#region ISESteroids
if ($ISESteroidsOnLoad) {

  Import-Module -Name ISESteroids

  if ($ISESteroidsOnDemand -eq $true) {
    Write-Output -InputObject '[ISESteroids] Press CTRL + F12 to launch.'
    $psISE.CurrentPowerShellTab.AddOnsMenu.Submenus.Add('Launch ISESteroids','CTRL+F12',{Start-Steroids})
  }
  else {
    if (Get-Command -Name 'Start-Steroids' -ErrorAction SilentlyContinue -and ([System.Windows.Input.Keyboard]::IsKeyDown('Ctrl')) -eq $false) {
      Start-Steroids
      Start-Sleep -Milliseconds 523
    }
  }
}
#endregion ISESteroids

Set-Location -Path $PSUserOneDrive