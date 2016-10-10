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

# $Id: sprite.ps1 199 2007-02-08 13:11:41Z adrian $

# demo1 for grrr.ps1
# run this as a script - do not 'source' it with '.'

$global:___globcheck___=1
$local:___globcheck___=2
if ($global:___globcheck___ -eq 2) {throw "This should not be sourced in global scope"}


cls
init-console 120 50
write-host "Bound sprites with DidExceedBounds handler changing motionpath and images"


function main {
  $pf = create-playfield -x 0 -y 2 -width 78 -height 48 -bg "black"
  $pf.showfps=$true

  $img1 = create-image "Hello","Windows","World" -fg "yellow" -bg "blue" -refx 3 -refy 1
  $img2 = create-image "bye","Win","World" -fg "blue" -bg "yellow" -refx 2 -refy 1
  $bounds = new-object Soapyfrog.Grrr.Core.Rect 5,5,30,20
  $rightmp = create-motionpath "1E"
  $leftmp = create-motionpath "1W"
  $script:invokecount = 0
  $h = create-spritehandler -DidExceedBounds { 
    $s = $args[0] # sprite
    $d = $args[1] # Delta
    $e = $args[2] # edges

    # Because we change the size of the sprite, we check both direction
    # and edge to determine if we're going out of bounds. 
    if ($d.dx -lt 0 -and $e -band [soapyfrog.grrr.core.edge]::Left) { 
      $s.MotionPath = $rightmp; 
      $s.images = $img1;
    } elseif ($d.dx -gt 0 -and $e -band [soapyfrog.grrr.core.edge]::right) {
      $s.MotionPath = $leftmp 
      $s.images = $img2;
    }
    $script:invokecount++
  }

  # create sprite and add properties one by one (sometimes easier to read)
  $sprite = create-sprite $img1 7 7 
  $sprite.bounds = $bounds
  $sprite.handler = $h
  $sprite.motionpath = $rightmp

  # game loop
  while ($true) {
    clear-playfield $pf

    move-sprite $sprite

    draw-string $pf "invokecount=$script:invokecount x=$($sprite.X) y=$($sprite.Y)" 0 0 -fg "red"
    draw-string $pf "bounds=$bounds" 0 1 -fg "cyan"
    draw-string $pf "sprite rect=$($sprite.rect)" 0 2 -fg "yellow"

    draw-sprite $pf $sprite

    flush-playfield $pf -sync 40 
  }
}

main

