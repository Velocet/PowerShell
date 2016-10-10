function Remove-Line
{

  Param
  (
    [string]$File = $null,
    [string]$String = $null
  )

  @(Get-Content -Path $File).Where{$_ -notmatch $String} | Set-Content -Path "$File.NEW"

  Rename-Item -Path $File -NewName "$File.BAK"
  Rename-Item -Path "$File.NEW" -NewName $File    

} # Remove line from file
