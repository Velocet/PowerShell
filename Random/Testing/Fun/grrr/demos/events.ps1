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

# run this as a script - do not 'source' it with '.'

$global:___globcheck___=1
$local:___globcheck___=2
if ($global:___globcheck___ -eq 2) {throw "This should not be sourced in global scope"}

# create an event map and set a script variable to false
$em = create-eventmap
$script:fired = $false

# after 5 processings, run the script to set the fired var to true
register-event $em -after 5 { 
  $em2 = $args[0] # the event map
  $num = $args[1] # the event number (ever incrementing counter)
  if ($script:em -ne $em2) { write-warning "map is not right" }
  $script:fired = $true; write-host -f "yellow" "bang!" 
  }

# do 4 and verify it hasn't fired yet
1..4 |% { process-eventmap $em }
if ($fired) { write-warning "shouldn't be fired yet" }

# one more and verify it has fired.
process-eventmap $em

if ($fired) {
  write-host "event fired, all is well" 
}
else { 
  write-warning "should be fired by now" 
}


