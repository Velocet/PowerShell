$UserSettingsFile = 'C:\Users\Velocet\OneDrive\Dokumente\WindowsPowerShell\Velocet\Microsoft.PowerShell_profile.ps1.xml'
[xml]$UserSettings = Get-Content $UserSettingsFile


$UserSettings.Save($UserSettingsFile)


Join-Path -Path $PSScriptRoot -ChildPath $MyInvocation.MyCommand.Name 

'1 ' + $MyInvocation.MyCommand.Name
'2 ' + $MyInvocation.ScriptName
'3 ' + $MyInvocation.InvocationName
'4 ' + $MyInvocation.PSCommandPath
'5 ' + $MyInvocation.PSScriptRoot
'6 ' + $MyInvocation.MyCommand.Definition
'7 ' + $PSScriptRoot
'8 ' + $PSCommandPath
$UserSettingsFile = $PSCommandPath + '.xml'
$UserSettingsFile
