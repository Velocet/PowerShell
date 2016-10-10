# https://geekeefy.wordpress.com/2016/07/21/imagetopowershellconsole/
function Write-Color {
  Param([Parameter()][string]$fc,[string]$bc) 
  Write-Host "          ░░░░░░░░░░▒▒▒▒▒▒▒▒▒▒▓▓▓▓▓▓▓▓▓▓██████████" -ForegroundColor $fc -BackgroundColor $bc -NoNewline
  Write-Host " - FC: $fc | BC: $bc"
  Write-Host "██████████▓▓▓▓▓▓▓▓▓▓▒▒▒▒▒▒▒▒▒▒░░░░░░░░░░          " -ForegroundColor $bc -BackgroundColor $fc -NoNewline
  Write-Host " - FC: $bc | BC: $fc"
}
function Write-Color2 {
  Param([Parameter()][string[]]$fc,[string]$bc) 
  Write-Host "██████████▓▓▓▓▓▓▓▓▓▓▒▒▒▒▒▒▒▒▒▒░░░░░░░░░░          " -ForegroundColor $fc -BackgroundColor $bc -NoNewline
  Write-Host " - FC: $fc | BC: $bc"
}

Clear-Host

Write-Output 'White/Black/Gray Variants'

Write-Color2 -fc 'Black' -bc 'White'
Write-Color -fc 'White' -bc 'Black'
Write-Color -fc 'White' -bc 'DarkYellow'
Write-Color -fc 'White' -bc 'Gray'
Write-Color -fc 'White' -bc 'DarkGray'

Write-Color2 -fc 'Black' -bc 'DarkYellow'
Write-Color -fc 'DarkYellow' -bc 'White'
Write-Color -fc 'DarkYellow' -bc 'Black'
Write-Color -fc 'DarkYellow' -bc 'Gray'
Write-Color -fc 'DarkYellow' -bc 'DarkGray'

Write-Color2 -fc 'Black' -bc 'Gray'
Write-Color -fc 'Gray' -bc 'White'
Write-Color -fc 'Gray' -bc 'Black'
Write-Color -fc 'Gray' -bc 'DarkYellow'
Write-Color -fc 'Gray' -bc 'DarkGray'

Write-Color2 -fc 'Black' -bc 'DarkGray'
Write-Color -fc 'DarkGray' -bc 'Black'
Write-Color -fc 'DarkGray' -bc 'White'
Write-Color -fc 'DarkGray' -bc 'DarkYellow'
Write-Color -fc 'DarkGray' -bc 'Gray'

$color = 'Red'
Write-Output 'Red Variants'
Write-Output "$color Variants"
Write-Output ''
Write-Color2 -fc $color -bc 'Black'
Write-Color -fc 'Black' -bc $color
Write-Color2 -fc $color -bc 'White'
Write-Color -fc 'White' -bc $color
Write-Color2 -fc $color -bc 'DarkYellow'
Write-Color -fc 'DarkYellow' -bc $color
Write-Color2 -fc $color -bc 'Gray'
Write-Color -fc 'Gray' -bc $color
Write-Color2 -fc $color -bc 'DarkGray'
Write-Color -fc 'DarkGray' -bc $color