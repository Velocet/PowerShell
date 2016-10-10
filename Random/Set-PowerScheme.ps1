<#
Using Windows PowerShell to Determine if a Laptop Is on Battery Power: https://blogs.technet.microsoft.com/heyscriptingguy/2010/07/31/using-windows-powershell-to-determine-if-a-laptop-is-on-battery-power/
Show all power schemes: "powercfg /l"
ToDo: Enable Battery Saver under Windows 10
#>

if ([BOOL](Get-WmiObject -Class BatteryStatus -Namespace root\wmi -ComputerName "localhost").PowerOnLine) {
    powercfg /s "381b4222-f694-41f0-9685-ff5bb260df2e"
    } # run if laptop is on power supply
else {
    powercfg /s "a1841308-3541-4fab-bc81-f71556f20b4a"
    } # run if laptop is on battery