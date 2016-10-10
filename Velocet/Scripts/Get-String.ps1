#TODO Implement grep -A, -i, search in files, search in files recurse
function Get-String {
  <#
      .SYNOPSIS
      grep-like Linux command.

      .DESCRIPTION
      Gets all matches from a pipeline input. Not case sensetive.

      Best used as an alias for grep: New-Alias -Name grep -Value Get-String ;)

      .PARAMETER Pattern
      The pattern you want to search for.
    
      .PARAMETER Line
      Number of lines to display before and after the match.

      .EXAMPLE
      Get-ChildItem -Path $env:windir | grep notepad
      23 -a----       11.09.2001     08:46         230000 notepad.exe

      Get all lines from the directory listing in $env:windir containing the word 'notepad'.
      First collumn indicates the line in which the pattern was found.

      .NOTES
      Needs more work to fully implement other grep features.

      .LINK
      https://GitHub.com/Velocet/PowerShell
  #>

  Param
  (
    [string]$Pattern
  )
  
    $input | Out-String -Stream | Select-String -Pattern $Pattern

} # grep