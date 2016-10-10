<#
    TODO Um ArrayListe erweitern: ein interface gleich erste spalte im array
    $array = New-Object System.Collections.ArrayList
    $array.Add('data')

    $InternalIP = @{
    'IPv4'    = ('10.0.0.1','10.0.0.1');
    'IPv6'    = ('ff::88','ff::88');
    'Virtual' = ($false,$true)
    }

    $InternalIP = @{
    'IPv4'    = $array1;
    'IPv6'    = $array2;
    'Virtual' = $array3;
    }
#>
function Get-InternalIP
{
  <#
      .SYNOPSIS
      Get the internal IPv4 and IPv6 address.

      .DESCRIPTION
      Gets the internal IPv4 and IPv6 address either for the physical adapter or the virtual adapter if running inside a virtual machine.

      .LINK
      https://GitHub.com/Velocet/PowerShell

      .Outputs
      System.Collections.Hashtable
  #>
  
  $InternalIP = @{
    'IPv4'    = $null;
    'IPv6'    = $null;
    'Virtual' = $null
  }

  # Get all not hidden physical and virtual network adapters
  $Adapter = Get-NetAdapter

  if ($Adapter | Where {$_.Virtual –eq $false -and $_.Status -eq 'Up'})
  {
    $Adapter = $Adapter | Where {$_.Virtual –eq $false -and $_.Status -eq 'Up'}
    $InternalIP.Virtual = $false
  } # Get the physical adapter IPv4 and IPv6 address
  else
  {
    $Adapter = $Adapter | Where {$_.Virtual –eq $true -and $_.Status -eq 'Up'}
    $InternalIP.Virtual = $true
  } # Get the virtual adapter IPv4 and IPv6 address if no physical adapter is installed (e.g. Hyper-V)

  $InternalIP.IPv4 = ($Adapter | Get-NetIPAddress -AddressFamily IPv4 -ErrorAction SilentlyContinue).IPAddress
  $InternalIP.IPv6 = ($Adapter | Get-NetIPAddress -AddressFamily IPv6 -ErrorAction SilentlyContinue).IPAddress
  
  return $InternalIP
  
} # Get internal IP v4 & v6