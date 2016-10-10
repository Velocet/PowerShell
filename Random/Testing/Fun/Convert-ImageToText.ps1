#------------------------------------------------------------------------------
# Copyright 2006 Adrian Milliner (ps1 at soapyfrog dot com)
# http://ps1.soapyfrog.com
#
# This work is licenced under the Creative Commons 
# Attribution-NonCommercial-ShareAlike 2.5 License. 
# To view a copy of this licence, visit 
# http://creativecommons.org/licenses/by-nc-sa/2.5/ 
# or send a letter to 
# Creative Commons, 559 Nathan Abbott Way, Stanford, California 94305, USA.
#------------------------------------------------------------------------------

# $Id: convert-image2text.ps1 91 2007-01-10 10:10:33Z adrian $

#------------------------------------------------------------------------------
# This script loads the specified image and outputs an ascii version to the
# pipe, line by line.
#
function Convert-ImageToText {
  param(
    [string]$path = $(throw "Supply an image path"),
    [int]$maxwidth = 40,            # default is width of console
    [string]$palette="shade",  # choose a palette, "ascii" or "shade"
    [float]$ratio = 1.8        # 1.5 means char height is 1.5 x width
  )

  # the next line is require because FromFile below throws a /zero (?!)
  $path=(resolve-path -erroraction "stop" $path).path

  $palettes = @{
    "ascii" = " .,:;=|iI+hHOE#`$"
    "shade" = " " + [char]0x2591 + [char]0x2592 + [char]0x2593 + [char]0x2588
    "bw"    = " " + [char]0x2588
  }
  $c = $palettes[$palette]
  if (-not $c) {
    write-warning "palette should be one of:  $($palettes.keys.GetEnumerator())"
    write-warning "defaulting to ascii"
    $c = $palettes.ascii
  }
  [char[]]$charpalette = $c.ToCharArray()

  # we need the drawing assembly
  $null = [System.Reflection.Assembly]::LoadWithPartialName("System.Drawing") 

  # load the image
  $image = [Drawing.Image]::FromFile($path)
  if ($maxwidth -le 0) { [int]$maxwidth = $host.ui.rawui.WindowSize.Width - 1}
  [int]$imgwidth = $image.Width
  [int]$maxheight = $image.Height / ($imgwidth / $maxwidth) / $ratio
  $bitmap = new-object Drawing.Bitmap ($image,$maxwidth,$maxheight)
  [int]$bwidth = $bitmap.Width; [int]$bheight = $bitmap.Height
  # draw it!
  $cplen = $charpalette.count
  for ([int]$y=0; $y -lt $bheight; $y++) {
    $line = ""
    for ([int]$x=0; $x -lt $bwidth; $x++) {
      $colour = $bitmap.GetPixel($x,$y)
      $bright = $colour.GetBrightness()
      [int]$offset = [Math]::Floor($bright*$cplen)
      $ch = $charpalette[$offset]
      if (-not $ch) { $ch = $charpalette[-1] } #overflow
      $line += $ch
    }
    $line
  }
}