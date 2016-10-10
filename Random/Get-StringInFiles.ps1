#region Stop Watch

$StopWatch = [Diagnostics.Stopwatch]::StartNew()
$StopWatch_ms = $StopWatch.ElapsedMilliseconds
$StopWatch_ticks = $StopWatch.ElapsedTicks

#endregion Stop Watch

function Get-StringInItem {
  
  Param(
    [Parameter(Mandatory=$true,HelpMessage='Pattern to search for.')]
    [String]$Pattern,
    
    [Parameter(Mandatory=$false,HelpMessage='Filter for specific files. Default: None.')]
    [String]$FileFilter = '*',
    
    [Parameter(Mandatory=$false,HelpMessage='Path to search in. Default: Current Location.')]
    [String]$Path = '.',
    
    [Parameter(Mandatory=$false,HelpMessage='Seach recursively.')]
    [Switch]$Rec = $false
  )

  $Items = Get-ChildItem -Filter $FileFilter -Path $Path -Recurse:$Rec | Where-Object { $_.Attributes -ne 'Directory'}

  foreach ($Item in $Items) {
    $Item = $Item | Select-String -Pattern $Pattern
    if ($Item) {
      $Item[0].Path + "\" + $Item[0].Filename
    }
  }
  return $ReturnResults

}

Get-StringInItem -FileFilter '*' -Path 'C:\Users\Velocet\Desktop\basic' -Pattern 'License' -Rec

Write-Output "[RUNTIME] $($($StopWatch.ElapsedTicks)-$StopWatch_ticks)ticks ($($($StopWatch.ElapsedMilliseconds)-$StopWatch_ms)ms)"
$StopWatch.Stop()