function Get-ExternalIPv4
{
  <#
      .SYNOPSIS
      Get external IPv4 address.

      .DESCRIPTION
      Contacts a server that responds with your external IPv4 address.
      
      If the query is slow, you could choose another built-in server ('-Server' parameter) or provide your own via the '-Uri' parameter.

      .PARAMETER Server
      Choose one of the built-in servers.

      .PARAMETER List
      Lists all built-in servers.

      .PARAMETER More
      Outputs even more info than the IP: Hostname, City, Region, Country, Location, Organisation, Postal

      .PARAMETER Uri
      Provide your own server for IP retrieval.

      Overrides the '-Server' parameter.

      .EXAMPLE
      Get-ExternalIPv4
      Get's the external IPv4 address via the standard defined built-in server.

      .EXAMPLE
      Get-ExternalIPv4 -Server 2
      Uses the second built-in server

      .EXAMPLE
      Get-ExternalIPv4 -List
      Lists all built-in servers.

      .NOTES
      If you want to change the standard defined server or want to add a server, just edit the script.

      .LINK
      https://GitHub.com/Velocet/PowerShell/
  #>

  Param (
    [int]$Server=0,
    [string]$Uri=$null,
    [switch]$List=$false,
    [switch]$More=$false
  )    
  
  $Servers = @(
    'http://diagnostic.opendns.com/myip',
    'http://api.ipify.org'
  ) # Server list. First one is default.
  $IPinfo = 'http://ipinfo.io/json' # Server with JSON output for more info.
  
  if ($List)
  {
    $Servers 
  }
  else
  {
    # If a number of servers in the array is provided then this server is choosen.
    # The default server that is choosen is always the first one (zero in the array).
    # To change the default server just add it as the first server in the list or
    # change the default number inside the Param-block.
    # If a URI is provided then this is choosen over any other option.
    $Uri = $Servers[$Server]
    if($Server -gt $Servers.Count)
    {
      $Uri = $Server
    }

    $WebClient = New-Object -TypeName 'Net.WebClient'
    
    if ($More)
    {
      ConvertFrom-Json -InputObject $($WebClient.DownloadString($IPinfo))
    } # Output ip, hostname, location and other info
    else
    {
      $WebClient.DownloadString($Uri)
    } # Use the normal server
    
    $WebClient.Dispose()
  }
  
} # Get external IPv4 address