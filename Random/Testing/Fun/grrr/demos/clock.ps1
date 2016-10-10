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

# $Id: clock.ps1 260 2007-02-18 08:45:08Z adrian $

# demo1 for grrr.ps1
# run this as a script - do not 'source' it with '.'

$global:___globcheck___=1
$local:___globcheck___=2
if ($global:___globcheck___ -eq 2) {throw "This should not be sourced in global scope"}




function main {
  $w=80; $h=50
  init-console $w $h
  $pf = create-playfield -x 0 -y 0 -width $w -height $h -bg "black"
  $pf.showfps=$true
  # can't rely on unicode literals and ps1 doesn't support unicode escapes :-(
  $txt = ([string][char]0x2666)*2  
  $secsImg = create-image @($txt,$txt) -bg "black" -fg "red"
  $minsImg = create-image @($txt,$txt) -bg "black" -fg "yellow"
  $hrsImg = create-image @($txt,$txt) -bg "black" -fg "green"

  $pi = [Math]::Pi
  $pd2 = $pi/2
  $twopi = 2*$pi

  $midx = $w/2
  $midy = $h/2

  $secsRadiusX = $midx * 0.9
  $secsRadiusY = $midy * 0.9
  $minsRadiusX = $secsRadiusX*0.9
  $minsRadiusY = $secsRadiusY*0.9
  $hrsRadiusX = $secsRadiusX*0.5
  $hrsRadiusY = $secsRadiusY*0.5

  while ($true) {
    clear-playfield $pf
    $n = get-date

    $hrsAngle = $twopi * (($n.Hour % 12 + ($n.Minute/60)) / 12 ) - $pd2
    $hrsX = $hrsRadiusX * [Math]::Cos($hrsAngle)
    $hrsY = $hrsRadiusY * [Math]::Sin($hrsAngle)
    draw-line $pf $midx $midy ($midx+$hrsX) ($midy+$hrsY) $hrsImg

    $minsAngle = $twopi * ($n.Minute / 60) - $pd2
    $minsX = $minsRadiusX * [Math]::Cos($minsAngle)
    $minsY = $minsRadiusY * [Math]::Sin($minsAngle)
    draw-line $pf $midx $midy ($midx+$minsX) ($midy+$minsY) $minsImg

    $s=($n.Second + ($n.Millisecond /1000) )
    $secsAngle = $twopi * ( $s / 60 ) - $pd2
    $secsX = $secsRadiusX * [Math]::Cos($secsAngle)
    $secsY = $secsRadiusY * [Math]::Sin($secsAngle)
    draw-line $pf -x1 $midx -y1 $midy -x2 ($midx+$secsX) -y2 ($midy+$secsY) $secsImg

    flush-playfield $pf -sync 40
  }
}

main

