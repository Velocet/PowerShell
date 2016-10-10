# http://stackoverflow.com/questions/4208694/how-to-speed-up-startup-of-powershell-in-the-4-0-environment
# http://stackoverflow.com/questions/2094694/how-can-i-run-powershell-with-the-net-4-runtime
function Update-GAC {
  Set-Alias -Name NGen -Value (Join-Path -Path ([System.Runtime.InteropServices.RuntimeEnvironment]::GetRuntimeDirectory()) -ChildPath 'ngen.exe')
  $Assemblies = [AppDomain]::CurrentDomain.GetAssemblies()

  foreach ($Assemblie in $Assemblies) {
    if($Assemblie.Location) {
      if(![System.Runtime.InteropServices.RuntimeEnvironment]::FromGlobalAccessCache($Assemblie)) {
        NGen /nologo install $_.location | % {"`t$_"}
      }
    }
  }
}