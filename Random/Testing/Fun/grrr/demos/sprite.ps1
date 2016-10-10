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

# $Id: sprite.ps1 260 2007-02-18 08:45:08Z adrian $

# demo1 for grrr.ps1
# run this as a script - do not 'source' it with '.'

$global:___globcheck___=1
$local:___globcheck___=2
if ($global:___globcheck___ -eq 2) {throw "This should not be sourced in global scope"}


cls
init-console 120 50
write-host "Sprites with manual (yellow) and path based (red) movement. Collisions are counted."


function main {
  $pf = create-playfield -x 0 -y 2 -width 78 -height 48 -bg "black"
  $pf.showfps=$true

  # create the anim frames for the yellow aliens
  $l1 = [char]0x2554 + [char]0x256a + [char]0x2557
  $l2a = [char]0x255d + " " + [char]0x255a
  $l2b = [char]0x2551 + " " + [char]0x2551
  $l2c = [char]0x255a + " " + [char]0x255d
  $imga1 = create-image $l1,$l2a -fg "yellow" -bg "black"
  $imga2 = create-image $l1,$l2b -fg "yellow" -bg "black"
  $imga3 = create-image $l1,$l2c -fg "yellow" -bg "black"

  # an array of sprites
  $sprites = @()
  # motion behaviour handlers - a somewhat manual approach - see below for alternative
  $handler = create-spritehandler -didinit {$args[0].state.dx = 1 } -didmove {
            $s = $args[0]; $st=$s.state
            if ($s.x -gt 72) { $s.y++; $s.state.dx=-1 }
            elseif ($s.x -lt 4) { $s.y--; $s.state.dx=1 }
            $s.x += $s.state.dx
          }
  $images = @($imga1,$imga2,$imga3,$imga2)
  # build a load of them
  0..31 | foreach {
    [int]$n=$_
    $x = [Math]::Floor($n / 4) * 7 + 4
    $y = ($n % 4) * 4 + 3
    $sa = create-sprite -images $images -x $x -y $y -handler $handler -animrate 8
    $sprites += $sa
  }

  $script:collisions = 0
  $script:other=$null

  # create another one with different behaviour
  $imgb = create-image "/\","\/" -fg "red" -bg "black"
  $mp = create-motionpath "20e 6ne 20n 4ne 4e 4se 4s 4sw 8w 12s 6sw 20w 5h" 3
  $h = create-spritehandler -didoverlap {
    $me = $args[0]; $other=$args[1];
    $script:collisions++
  } -didendmotion {
    $script:other="red motion ended"
  }
  $spr = create-sprite -images @($imgb) -x 10 -y 42  -motionpath $mp -handler $h

  # game loop
  $debugline=" "
  while ($true) {
    clear-playfield $pf
    draw-string $pf $debugline 0 0 red
    if ($script:other) { draw-string $pf $script:other 0 1 cyan }
    #move all
    move-sprite $sprites
    move-sprite $spr
    #draw all
    draw-sprite $pf $sprites
    draw-sprite $pf $spr
    test-spriteoverlap $spr $sprites 
    flush-playfield $pf -sync 20 
    $debugline = "collisions=$collisions"
  }
}

main

