Add-Type -Type @"
using System;
using System.Runtime.InteropServices;
namespace Huddled {
   public class Dwm {
   
      [DllImport("user32.dll")]
      public static extern int SetWindowLong(IntPtr hWnd, int nIndex, int dwNewLong);
      
      [DllImport("user32.dll", SetLastError=true)]
      public static extern int GetWindowLong(IntPtr hWnd, int nIndex);

      [DllImport("user32.dll")]
      public static extern bool SetLayeredWindowAttributes(IntPtr hwnd, uint crKey, byte bAlpha, uint dwFlags);

      
      [DllImport("dwmapi.dll", PreserveSig = false)]
      [return: MarshalAs(UnmanagedType.Bool)]
      public static extern bool DwmIsCompositionEnabled();
        
      [DllImport("dwmapi.dll")]
      public static extern void DwmEnableBlurBehindWindow(IntPtr hwnd, ref BlurSettings blurBehind);
      
      [DllImport("dwmapi.dll", PreserveSig = true)]
      public static extern int DwmExtendFrameIntoClientArea(IntPtr hwnd, ref Margins margins);

      [StructLayout(LayoutKind.Sequential)]
      public struct Margins
      {
         public int leftWidth;
         public int rightWidth;
         public int topHeight;
         public int bottomHeight;
      }

      [StructLayout(LayoutKind.Sequential)]
      public struct BlurSettings
      {
         public int dwFlags;
         public bool fEnable;
         public IntPtr hRgnBlur;
         public bool fTransitionOnMaximized;
         public BlurSettings(bool enable) {
            dwFlags = 5; // enable
            fEnable = enable;
            hRgnBlur = IntPtr.Zero;
            fTransitionOnMaximized = true;
         }
         
         public BlurSettings(bool enable, bool maximizeTransition) {
            dwFlags = 5; // enable
            fEnable = enable;
            fTransitionOnMaximized = maximizeTransition;
            hRgnBlur = IntPtr.Zero;
         }      
      }
      
      [StructLayout(LayoutKind.Sequential)]
      public struct ColorRef
      {
         public uint ColorDWORD;

         public ColorRef(System.Drawing.Color color)
         {
            ColorDWORD = (uint)color.R + (((uint)color.G) << 8) + (((uint)color.B) << 16);
         }

         public System.Drawing.Color Color {
            get 
            {
               return System.Drawing.Color.FromArgb((int)(0x000000FFU & ColorDWORD),
                  (int)(0x0000FF00U & ColorDWORD) >> 8, (int)(0x00FF0000U & ColorDWORD) >> 16);
            }
            set
            {
               ColorDWORD = (uint)value.R + (((uint)value.G) << 8) + (((uint)value.B) << 16);
            }
         }
      }
   }
}
"@ -Ref System.Drawing

function global:Set-Blur {
   #.Synopsis
   # Mess with the transparency and blur of the PowerShell window
   #.Parameter color
   # The color to treat as transparent (you can set this to your foreground or background for best effect, but you must pass an actual [Drawing.Color]
   #.Parameter opacity
   # On a scale of 0 to 255, how opaque to make the window (255 is no transparency, 0 is invisible)
   #.Parameter blur
   # If set, -blur turns on the DWM Blur-Behind, otherwise turns it off
   #.Parameter Opaque
   # If set, turns off the color and opacity settings
   #.Parameter Handle
   # The handle of the window to act on. Defaults to the current PowerShell window
   #.Example 
   # Set-Blur -Color ([System.Drawing.Color]::FromArgb( 0xff, 1, 36, 86 )) -Blur
   #
   # Makes the PowerShell Blue color transparent, and applies the window blur
   #.Example 
   # Set-Blur -Color ([System.Drawing.Color]::FromArgb( 0xff, 1, 36, 86 ))
   #
   # Makes the PowerShell Blue color completely transparent
   #.Example 
   # Set-Blur -Opacity 200
   #
   # Sets the window partly transparent
   param([System.Drawing.Color]$color, [byte]$opacity, [switch]$Blur, [switch]$Opaque, [IntPtr]$handle = (ps -Id $pid).MainWindowHandle)
   
   if($opaque) { 
      $style = [Huddled.Dwm]::GetWindowLong($handle, -20) -bor 0x80000 -bxor 0x80000
   } else {
      $style = [Huddled.Dwm]::GetWindowLong($handle, -20) -bor 0x80000      
   }
   $style = [Huddled.Dwm]::SetWindowLong($Handle, -20, $style);

   $flag = 0
   if($color) { $flag += 1 } else { $color = [System.Drawing.Color]::Black }
   if($opacity) { $flag += 2 } else { $opacity = 255 }
   
   ## This is why I wanted to console color ... you want to set this to your actual console background color
   $colorRef = (New-Object Huddled.DWM+ColorRef $color).ColorDWORD
   
   $null = [Huddled.Dwm]::SetLayeredWindowAttributes($handle, $colorRef, $opacity, $flag)
   if([Huddled.Dwm]::DwmIsCompositionEnabled()) {
      $blurSettings = New-Object Huddled.Dwm+BlurSettings $blur
      $null = [Huddled.Dwm]::DwmEnableBlurBehindWindow($handle, [ref]$blurSettings);
   }
}