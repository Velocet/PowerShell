#Quick and dirty powershell screenshot function

function Invoke-ScreenGrabber
{
    param(
        [switch]$HideWindow,
        [switch]$PassThru
    )

    # Ensure Windows Forms assembly is available
    $null = Add-Type -AssemblyName System.Windows.Forms -ErrorAction SilentlyContinue

    # Set up bitmap to hold our screenshot
    $PrimaryScreen = [System.Windows.Forms.Screen]::PrimaryScreen
    $bmp = New-Object System.Drawing.Bitmap -ArgumentList ($PrimaryScreen.Bounds.Width,$PrimaryScreen.Bounds.Height)
    $gfx = [System.Drawing.Graphics]::FromImage($bmp) -as [System.Drawing.Graphics]

    if($HideWindow)
    {
        # Import ShowWindow
        $DllImportSplat = @{
            MemberDefinition = @'
                [DllImport("user32.dll")]
                public static extern bool ShowWindow(IntPtr hWnd, int nCmdShow);
'@
            Namespace        = ($ns = "ns$([guid]::NewGuid())".Replace('-','')) 
            Name             = "type$ns"
            PassThru         = $true
        }
        $WindowAPI = Add-Type @DllImportSplat

        # Hide host window and wait for aero animation
        # 250ms should be enough for default minimize animation in Win10
        $thisWindow = (Get-Process -Id $PID).MainWindowHandle
        $null = $WindowAPI::ShowWindow($thisWindow, 2)
        Start-Sleep -Milliseconds 250

        # Grab pixels from screen
        $gfx.CopyFromScreen(0,0,0,0, $bmp.Size)

        # Restore host window from minimized staate
        $null = $WindowAPI::ShowWindow($thisWindow, 9)
    }
    else
    {
        # Grab pixels from screen
        $gfx.CopyFromScreen(0,0,0,0, $bmp.Size)    
    }

    # Allocate temp file, save bitmap as png to it
    $tf = [System.IO.Path]::GetTempFileName()
    $bmp.Save($tf, "Png")

    # Rename to *.png
    $ScreenShot = Get-Item $tf |Rename-Item -NewName { $_.Name -replace "$([regex]::Escape($_.Extension))$",'.png' } -PassThru

    if($PassThru)
    {
        # Return FileInfo object
        return $ScreenShot
    }
    else
    {
        # otherwise launch picture
        Start-Process $ScreenShot.FullName
    }
}