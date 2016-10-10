function Set-PSWindowPosition {
  # From: http://powershell.com/cs/forums/p/7062/11529.aspx#11529
  Param([int]$NewX,[int]$NewY)

  Begin {
    $Signature = @'
[DllImport("user32.dll")]
public static extern bool MoveWindow(IntPtr hWnd,int X,int Y,int nWidth,int nHeight,bool bRepaint);
[DllImport("user32.dll")]
public static extern IntPtr GetForegroundWindow();
[DllImport("user32.dll")]
public static extern bool GetWindowRect(HandleRef hWnd,out RECT lpRect);
public struct RECT {
    public int Left;        // x position of upper-left corner
    public int Top;         // y position of upper-left corner
    public int Right;       // x position of lower-right corner
    public int Bottom;      // y position of lower-right corner
}
'@
    Add-Type -MemberDefinition $Signature -Name WinUtils -Namespace WindowsUtilities
  }
  
  Process {
    try {
      $Object = New-Object -TypeName System.Object
      $Handle = [WindowsUtilities.WinUtils]::GetForegroundWindow()
      $HandleRef = New-Object -TypeName System.RunTime.InteropServices.HandleRef -ArgumentList $Object, $Handle
      $Rect = New-Object WindowsUtilities.WinUtils+RECT
      $null = [WindowsUtilities.WinUtils]::GetWindowRect($HandleRef, [ref]$Rect)
 
      #$Resolution = (Get-WmiObject -Class Win32_VideoController).VideoModeDescription -split(' x ')
      #$Width = $Resolution[0]
      #$Height = $Resolution[0]
      
      $Width = $Rect.Right - $Rect.Left
      #$Height = $Rect.Top - $Rect.Bottom
      Write-Host "[BEFORE] " -NoNewline
      Write-Host "Right: $($Rect.Right) " -NoNewline
      Write-Host "Left: $($Rect.Left)" -NoNewline
      Write-Host "Top: $($Rect.Top)" -NoNewline
      Write-Host "Bottom: $($Rect.Bottom)" -NoNewline
      Write-Host "Width: $Width" -NoNewline
      Write-Host "Height: $Height"

      $Height = 700
    
      $null = [WindowsUtilities.WinUtils]::MoveWindow($Handle, $NewX, $NewY, $Width, $Height, $true)
      $null = [WindowsUtilities.WinUtils]::GetWindowRect($HandleRef, [ref]$Rect)
      
      Write-Host " [AFTER] " -NoNewline
      Write-Host "Right: $($Rect.Right) " -NoNewline
      Write-Host "Left: $($Rect.Left)" -NoNewline
      Write-Host "Top: $($Rect.Top)" -NoNewline
      Write-Host "Bottom: $($Rect.Bottom)" -NoNewline
      Write-Host "Width: $Width" -NoNewline
      Write-Host "Height: $Height"
    }
    
    catch {
      Write-Error -Message “`n[EXCEPTION] Message: $($_.Exception.Message)”
    }
  } 
}