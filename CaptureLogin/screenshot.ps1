function Get-WIAShot 
{ 
 
#requires -version 2.0 
 
<# 
.Synopsis 
   Use PowerShell and WIA to take snapshots from a compatible camera or webcam 
.Description 
   This PowerShell script takes snapshots from your camera or webcam to JPEG file format 
   Tested on XP - requires WIA installed.  
   You can use some other program like the old vidcap32.exe from MSFT to change the  
   resolution of the captured image, i.e increase it to 640x480  
.Parameter Append 
   Do not overwrite images, append incremental number to each file name  
   e.g picture1.jpg, picture2.jpg 
.Parameter BaseName 
   The base name of the target file name - file name minus extension 
   defaults to Basename "picture"  
   e.g picture.jpg is created if none specified 
.Parameter Dir 
   The target directory where images are saved 
   defaults to Dir "C:\temp" if none specified 
.Parameter Interval 
   Interval in seconds between shots 
   Note camera make take up to 5 seconds to initialise in addition to this time 
.Parameter Photos 
   The number of photos to take - use 64000 for max 
.Parameter ShowMe 
   Open image in default jpg image viewer 
.example 
   Get-WIAShot 
       
   Description 
   ----------- 
   One photo snapshot is taken and saved to c:\temp\picture.jpg 
.example 
   Get-WIAShot -verbose 
       
   Description 
   ----------- 
   Script logs output in console 
.example 
   Get-WIAShot -Append -Photos 1000 
       
   Description 
   ----------- 
   One Thousand photo snapshots are taken at the fastest possible rate and  
   to saved to file names - picture1.jpg, picture2.jpg, picture3.jpg, etc 
.Link 
   http://social.technet.microsoft.com/Profile/en-US/?user=Matthew Painter 
.Link 
   http://www.microsoft.com/downloads/en/details.aspx?FamilyID=a332a77a-01b8-4de6-91c2-b7ea32537e29 
.Notes 
   NAME:      Get-WIAShot 
   VERSION:   1.0 
   AUTHOR:    Matthew Painter 
   LASTEDIT:  26/09/2010 
 
#> 
   [CmdletBinding()]    
    
      Param ( 
      [Parameter( 
      ValueFromPipeline=$False, 
      Mandatory=$False, 
      HelpMessage="Do not overwrite images, append incremental number to each file name")] 
      [switch]$Append, 
       
      [Parameter( 
      ValueFromPipeline=$False, 
      Mandatory=$False, 
      HelpMessage="The base name of the target file name - file name minus extension")] 
      [string]$BaseName="picture",  
       
      [Parameter( 
      ValueFromPipeline=$False, 
      Mandatory=$false, 
      HelpMessage="The target directory where images are saved")] 
         [string]$Dir="C:\temp", 
       
      [Parameter( 
      ValueFromPipeline=$False, 
      Mandatory=$false, 
      HelpMessage="Interval in seconds between shots, note camera make take up to 5 seconds to initialise in addition to this time")] 
      [int]$Interval=0, 
          
      [Parameter( 
      ValueFromPipeline=$False, 
      Mandatory=$false, 
      HelpMessage="The number of photos to take - use 64000 for max")] 
      [int]$Photos=1, 
          
      [Parameter( 
      ValueFromPipeline=$False, 
      Mandatory=$false, 
      HelpMessage="open image in default jpg image viewer")] 
      [switch]$ShowMe 
      ) 
 
   new-item $Dir -itemtype dir -force | out-null   
 
   #$ErrorActionPreference="silentlycontinue" 
   $WIAManager = new-object -comobject WIA.DeviceManager 
   if (!$?) { 
      return "Unable to Create a WIA Object" 
   } 
    
   $DeviceList = $WIAManager.DeviceInfos 
   if ($DeviceList.Count -gt 0) { 
      $Device=$DeviceList.item($DeviceList.Count) 
   } else { 
      return "No Device Connected" 
   } 
 
   $ConnectedDevice = $Device.connect() 
   if (!$?) { 
      return "Unable to Connect to Device" 
   } 
 
   $Commands = $ConnectedDevice.Commands 
   $TakeShot="Not Found" 
   foreach ($item in $Commands) { 
      if ($item.name -match "take") { 
         $TakeShot=$item.CommandID 
      } 
   } 
    
   if ($TakeShot -eq "Not Found") { 
      return "Attached Camera does not support the WIA Command - Take Picture" 
   } 
 
   $Snaps=1 
   $c=0 
   $Base=$BaseName 
   do 
   { 
      if ($Append) 
      {          
         do  
         { 
            $c++ 
            $BaseName="$Base$c" 
         } while (Test-Path "$Dir\$Base$c.jpg") 
      } 
      $Pcount=$ConnectedDevice.items.Count 
      Write-Verbose "Taking photo $Snaps of $Photos" 
      $ConnectedDevice.ExecuteCommand($TakeShot) | out-null 
      trap{Write-Verbose "Error - can't take picture. Camera may be in use."; continue} 
      if ($ConnectedDevice.items.Count -gt $Pcount)  
      { 
         Write-Verbose "Camera has taken a picture" 
         $Pcount=$ConnectedDevice.items.Count 
         Write-Verbose "$Pcount images on camera"  
           
         $Picture=$ConnectedDevice.items.item($ConnectedDevice.items.Count) 
         Write-Verbose "Transfering image" 
         $Imagefile="" 
         $ImageFile=$Picture.Transfer() 
         Write-Verbose "Saving image" 
         if ($ImageFile.FileExtension -eq "jpg")  
         { 
             if (test-path "$Dir\$BaseName.jpg")  
             { 
                del "$Dir\$BaseName.jpg" 
             } 
             $ImageFile.SaveFile("$Dir\$BaseName.jpg") 
             Write-Verbose "Saved file $Dir\$BaseName.jpg" 
             
             $ConnectedDevice.items.Remove($ConnectedDevice.items.Count) 
             Write-Verbose "Removed last image from camera" 
             $Pcount=$ConnectedDevice.items.Count     
             Write-Verbose "$Pcount images on camera" 
             if ($ShowMe) 
             { 
                Write-Verbose "Displaying image" 
                invoke-item "$Dir\$BaseName.jpg" 
             }  
             Write-Verbose " " 
             if ($Interval -gt 0 -and $Snaps -lt $Photos) 
             { 
                Write-Verbose "$Interval Seconds before next photo" 
                start-sleep -s $interval  
             }         
         } 
      } 
      $Snaps++    
   } 
   while ($Snaps -le $Photos)    
} 