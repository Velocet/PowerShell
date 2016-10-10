#------------------------------------------------------------------------------
# Copyright 2006-2007 Adrian Milliner (ps1 at soapyfrog dot com)
# http://ps1.soapyfrog.com
#
# This work is licenced under the Creative Commons 
# Attribution-NonCommercial-ShareAlike 2.5 License. 
# To view a copy of this licence, visit 
# http://creativecommons.org/licenses/by-nc-sa/2.5/ 
# or send a letter to 
# Creative Commons, 559 Nathan Abbott Way, Stanford, California 94305, USA.
#------------------------------------------------------------------------------

# $Id: scramble.ps1 290 2007-02-22 15:52:15Z adrian $

# demo1 for grrr.ps1
# run this as a script - do not 'source' it with '.'

$global:___globcheck___=1
$local:___globcheck___=2
if ($global:___globcheck___ -eq 2) {throw "This should not be sourced in global scope"}



# load modules
cls

$cw = 78 # reqd for tile wrapping to work
init-console 80 50
write-host "Experimental tilemap support"

#--------------------------------------------------------------------
# Parallax scrolling demo
#
function main {
  $pf = create-playfield -x 0 -y 2 -width $cw -height 33 -Background "black"
  $pf.showfps=$true

  $imga = create-image "'''","'''" -Foreground "blue" -Background "darkmagenta"
  $imgb = create-image "@@@","@@@" -Foreground "darkblue" -Background "darkmagenta"

  $imgc = create-image "{|}","{:}" -Foreground "red" -Background "darkred"
  $imgd = create-image "/=\","\=/" -Foreground "yellow" -Background "red"
  $imge = create-image "\=/","/=\" -Foreground "yellow" -Background "red"
  
  $imgx = create-image "<=>"," W " -Foreground "magenta" -Background "black"
  $imgy = create-image " | ","/%\" -Foreground "yellow" -Background "black" -transparent 32

  $map = @{"A"=$imga; "B"=$imgb; "C"=$imgc; "D"=$imgd; "E"=$imge; "X"=$imgx; "Y"=$imgy}

  $backlines  = "                   BA                                        BA     ",
                "BBA        BA      BBA                BBBBBBA        BA      BBA    ",
                "BBBBA    BBBBA   BBBBBA              BBBBBBBBBA    BBBBA   BBBBBA   ",
                "BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB"

  $frontlines = "     C         D       E                     C         D       E  ", 
                "    CCC       YC       C                    CCC       YC       C  ",  
                "     C        CC    Y  CC     Y              C        CC    Y  CC ",
                "     CCC  X   CCC   CCCCCC X CCC  Y          CCC  X   CCC   CCCCCC",
                "CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC"

  $backtm = create-tilemap $backlines $map 
  $fronttm = create-tilemap $frontlines $map 

  #wrap points
  [int]$backwp = $backtm.tilewidth * $backtm.mapwidth-$cw
  [int]$frontwp = $backtm.tilewidth * $fronttm.mapwidth-$cw

  # create sprites to complete the look
  $thrustimg1 = create-image @(">") -Foreground "yellow" -Background "black"
  $thrustimg2 = create-image @("=") -Foreground "red" -Background "black"
  $rocketimg = create-image " o  ","D#>-" -Foreground "white" -Background "black"

  $mp = create-motionpath "5n 5h 7e 2h 5sw 2h 2w" 
  $thrustsprite = create-sprite -images $thrustimg1,$thrustimg2 -x 4 -y 9 -motionpath $mp
  $rocketsprite = create-sprite -images @($rocketimg) -x 5 -y 8 -motionpath $mp

  $sprites = $thrustsprite,$rocketsprite

  # game loop
  [int]$fc = 0;
  while ($true) {
    $fc++
    $fx = $fc % $frontwp
    $bx = [Math]::Floor($fc/2) % $backwp

    clear-playfield $pf
    draw-tilemap $pf $backtm -offsetx $bx -offsety 0 -x 0 -y 25 -w $cw -h 12
    draw-tilemap $pf $fronttm -offsetx $fx -offsety 0 -x 0 -y 24 -w $cw -h 15
    move-sprite $sprites
    draw-sprite $pf $sprites
    flush-playfield $pf -sync 20
  }
}

main

