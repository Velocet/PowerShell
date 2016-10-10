#TODO implement CowSay: https://en.wikipedia.org/wiki/Cowsay
#TODO Implement fortune from *nix with % functionality to diretly import fortune files
# https://sources.debian.net/src/fortunes-de/0.32-1/data/
# https://sources.debian.net/src/fortune-mod/1:1.99.1-7/datfiles/off/unrotated/
# https://sources.debian.net/src/fortune-mod/1:1.99.1-7/datfiles/
# http://www.asciiartfarts.com/fortune.txt
function Get-Fortune
{
  <#
      .SYNOPSIS
      Get your personal fortune cookie!

      .DESCRIPTION
      Queries a online service to get you a fortune cookie.

      .PARAMETER Online
      Contact the original excuses server instead of using the local db.

      .LINK
      https://GitHub.com/Velocet/PowerShell/

      .LINK
      http://pages.cs.wisc.edu/~ballard/bofh/
  #>
  
  # Generate your personal fortune feed: http://wertarbyte.de/gigaset-rss/
  $Uri = 'http://wertarbyte.de/gigaset-rss/?offensive=1&limit=140&cookies=1&lang=de&lang=en&format=rss&jar_id=47890485652059026906764953130202578209361565210116094'
  
  $WebClient=New-Object -TypeName 'Net.WebClient'
  
  $Fortune = [xml]($WebClient.DownloadString($Uri))
  $Fortune = $Fortune.rss.channel.item.title
  
  $WebClient.Dispose()
  
  return $Fortune
  
} # Get fortune cookie