#region Stop Watch

https://mjolinor.wordpress.com/2014/06/03/invoke-scritptasync-v2/
http://stackoverflow.com/questions/28850652/how-to-kill-threads-started-in-powershell-script-on-stop

$StopWatch = [Diagnostics.Stopwatch]::StartNew()
$StopWatch_ms = $StopWatch.ElapsedMilliseconds
$StopWatch_ticks = $StopWatch.ElapsedTicks

#endregion Stop Watch


$MaxThreads = $(Get-WmiObject win32_computersystem -Filter "NumberOfLogicalProcessors!=0" -Property NumberOfLogicalProcessors).NumberOfLogicalProcessors
$RunspacePool = [RunspaceFactory ]::CreateRunspacePool(1, $MaxThreads)
$RunspacePool.Open()

$ScriptBlock = {
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
      $RunResult += $Item[0].Path + "\" + $Item[0].Filename + "`n"
    }
  }
  Return $RunResult
}
 
$Jobs = @()

#Get-StringInItem -FileFilter '*' -Path 'C:\Users\Velocet\Desktop\Parent' -Pattern 'License' -Rec
#$Pattern = 'License'

$Job = [powershell]::Create().AddScript($ScriptBlock).AddArgument($Pattern)
$Job.RunspacePool = $RunspacePool
$Jobs += New-Object PSObject -Property @{
  Pipe = $Job
  Result = $Job.BeginInvoke()
}

<#
    Write-Host "Waiting.." -NoNewline
    Do {
    Write-Host "." -NoNewline
    Start-Sleep -Seconds 1
    } While ( $Jobs.Result.IsCompleted -contains $false )
    Write-Host "All jobs completed!"
#>

$Results = @()
ForEach ($Job in $Jobs )
{   $Results += $Job.Pipe.EndInvoke($Job.Result)
}
Return $Results

Get-StringInItem -FileFilter '*' -Path 'C:\Users\Velocet\Desktop\Parent' -Pattern 'License' -Rec
#$Results

Write-Output "[RUNTIME] $($($StopWatch.ElapsedTicks)-$StopWatch_ticks)ticks ($($($StopWatch.ElapsedMilliseconds)-$StopWatch_ms)ms)"
$StopWatch.Stop()