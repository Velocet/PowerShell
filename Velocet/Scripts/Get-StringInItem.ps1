function Get-StringInItem {  

  Param(
    [Parameter(Mandatory, HelpMessage='Pattern to search for.')]
    [String]$Pattern,    
    [String]$FileFilter = '*',    
    [String]$Path       = '.',    
    [Switch]$Rec        = $false
  )    

  $Items = Get-ChildItem -Filter $FileFilter -Path $Path -Recurse:$Rec -File

  foreach ($Item in $Items)
  {

    $Item = $Item | Select-String -Pattern $Pattern # Select items with matching pattern

    if ($Item)
    {
      $Item[0].Path
    } # Test if match

  } # Return path + filename for every match

} # Search for string in Item(s)