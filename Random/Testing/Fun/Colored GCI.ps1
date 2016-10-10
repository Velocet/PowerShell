function Color-Me 
{
  param(  
    [Parameter(Mandatory = $true,Position = 0,valueFromPipeline = $true)    ]
    [Alias('input')]
    $FilePath
  )
 
  BEGIN {
    $origFg = $host.ui.rawui.foregroundColor 
  }
 
  PROCESS {
    foreach ($Item in $Input)  
    { 
      if ($Item.Mode.StartsWith('d')) {
        $host.ui.rawui.foregroundColor = 'Green'
      } else {
        switch -regex ($Item.Extension) {
          #Executables & Installers
          "\.(exe|msi)$" {$host.ui.rawui.foregroundColor = "Blue"} 
          #Archives
          "\.(zip|rar|7z|gz|tar)$" {$host.ui.rawui.foregroundColor = "Cyan"} 
          #Scripts
          "\.(cmd|vbs|js|ps1|sh|psm1|psd1)$"    {$host.ui.rawui.foregroundColor = "DarkCyan"} 
          #Audio
          "\.(mp3|wav|wma)$" {$host.ui.rawui.foregroundColor = "DarkGray"} 
          #Video
          "\.(avi|mkv|mp4)$" {$host.ui.rawui.foregroundColor = "DarkGreen"} 
          #Documents
          "\.(pptx|docx|xlsx|pdf)$" {$host.ui.rawui.foregroundColor = "DarkRed"} 
          #text files
          "\.(txt|log)$" {$host.ui.rawui.foregroundColor = "Gray"}          
          #DiskImages
          "\.(iso|bin)$" {$host.ui.rawui.foregroundColor = "Magenta"}        
          #Downloads
          "\.(torrent|nzb)$" {$host.ui.rawui.foregroundColor = "Red"}        
          #Images
          "\.(png|jpg)$" {$host.ui.rawui.foregroundColor = "Yellow"}       
          default {$host.ui.rawui.foregroundColor = $origFg}
        }
      } 
      return $Item
    }  
  }
    
  END {
    $host.ui.rawui.foregroundColor = $origFg    
  }
}