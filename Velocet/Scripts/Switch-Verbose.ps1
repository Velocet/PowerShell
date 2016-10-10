function Switch-Verbose
{

  Param
  (
    [switch]$Verbose
  )
  
  if($Verbose)
  {

    $OldVerbose = $VerbosePreference
    $VerbosePreference = 'Continue'

    Write-Verbose -Message 'Verbose Output: On'

  }
  else
  {

    Write-Output -InputObject 'Verbose Output: Off'

  }

  $VerbosePreference = $OldVerbose

} # Switch verbose output on/off
