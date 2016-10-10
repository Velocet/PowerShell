# Microsoft Windows Powershell Module Script
#
# Name: Invoke-AsAdmin
# Version: 0.0.0.3
# Author: Michal Millar
# https://github.com/michalmillar
# http://www.bolis.com
#
#
# Description:
# Provides cmdlet, process, and session elevation in PowerShell.
#
# License: 
# The MIT License (MIT, Expat)
#
# Copyright (c) 2014 msumimz
# Copyright (c) 2016 The Bolis Group
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

Function script:Get-Base64String([string]$s) {
  $bytes = [System.Text.Encoding]::Unicode.GetBytes($s)
  [Convert]::ToBase64String($bytes)
}

$script:formatter = new-object Runtime.Serialization.Formatters.Binary.BinaryFormatter

Function script:ConvertTo-PrintableRepr($obj) {
  $fs = new-object IO.MemoryStream
  $formatter.Serialize($fs, $obj)
  $bytes = new-object byte[] ($fs.length)
  [void]$fs.Seek(0, "Begin")
  [void]$fs.Read($bytes, 0, $fs.length)
  [Convert]::ToBase64String($bytes)
}

$script:deserializerString = @'
Function script:ConvertFrom-PrintableRepr($repr) {
  $formatter = new-object Runtime.Serialization.Formatters.Binary.BinaryFormatter
  $bytes = [Convert]::FromBase64String($repr)
  $fs = new-object IO.MemoryStream
  [void]$fs.Write($bytes, 0, $bytes.length)
  [void]$fs.Seek(0, "Begin")
  $formatter.Deserialize($fs)
}
'@

$script:runnerString = @'
$serializable = $null
$output = $null
filter SendTo-Pipe() {
  if ($null -eq $serializable) {
    $script:serializable = $_.GetType().IsSerializable
    if (!$serializable) {
      $script:output = new-object System.Collections.ArrayList
    }
  }
  if ($serializable) {
    $outPipe.WriteByte(1)
    $formatter.Serialize($outPipe, $_)
  }
  else {
    [void]$output.Add($_)
  }
}

$formatter = new-object Runtime.Serialization.Formatters.Binary.BinaryFormatter
set-location $location
try {
  try {
    $outPipe = new-object IO.Pipes.NamedPipeClientStream ".", $pipeName, "Out"
    $outPipe.Connect()

    if ($arglist.length -eq 0 -and $command -is [string]) {
      invoke-expression $command 2>&1 | SendTo-Pipe
    }
    else {
      & $command @arglist 2>&1 | SendTo-Pipe
    }
    if (!$serializable) {
      foreach ($s in $output | out-string -stream) {
        $outPipe.WriteByte(1)
        $formatter.Serialize($outPipe, $s)
      }
    }
  }
  catch [Exception] {
    $outPipe.WriteByte(1)
    $formatter.Serialize($outPipe, $_)
  }
}
finally {
  $outPipe.WriteByte(0)
  $outPipe.WaitForPipeDrain()
  $outPipe.Close()
}
'@

<#
.SYNOPSIS
    Execute a command as an elavated user.

.DESCRIPTION
    The Invoke-AsAdmin cmdlet executes the command specified by the arguments as an elavated user.

    When the command is a single string, it is executed by Invoke-Expression; otherwise, "& command" is used.

    The command is executed in an elavated process that is different from the caller. The output is serialized and transfered as pipeline stream to the caller. If the output is not serializable, it is converted to the string stream by means of the Out-String cmdlet.

    Compared to "Start-Process -Verb Runas", the Invoke-AsAdmin cmdlet won't open a new console window. Instead, it executes a command in the same window as the caller process.

.EXAMPLE
    PS> Invoke-AsAdmin cmd /c mklink $env:USERPROFILE\bin\test.exe test.exe
    Creates a symbolic link to test.exe in the $env:USERPROFILE\bin folder. Note that $env:USERPROFILE is evaluated in the context of the caller process.

.EXAMPLE
   PS> Invoke-AsAdmin "Get-Process -IncludeUserName | Sort-Object UserName | Select-Object UserName, ProcessName"
   Obtains a process list with user name information, sorted by UserName. Because the System.Diagnostics.Process objects are not serializable, if you want to transform the output of Get-Process, enclose the whole command line with double quotes to ensure that pipeline processing should be done in the callee process.
#>
Function Invoke-AsAdmin {

    [CmdletBinding()]
    Param(
        [Parameter(Position=0, ValueFromRemainingArguments=$true)]
        $__Args
    )

    Set-StrictMode -Version 3

    if ($null -eq $__Args) {
        Write-Error "Command to execute not specified"
        return
    }

    $pipeName = "Invoke-AsAdmin_" + [guid].guid.ToString()
    $args = @($__Args)
    $commandString =
        $deserializerString + "`n" +
        "`$pipeName = `'" + $pipeName + "`'`n" +
        "`$location = ConvertFrom-PrintableRepr `'" + (ConvertTo-PrintableRepr (get-location).Path) + "`'`n" +
        "`$command = ConvertFrom-PrintableRepr `'" + (ConvertTo-PrintableRepr $args[0]) + "`'`n"
    if ($args.Length -gt 1) {
        $commandString += "`$arglist = @(ConvertFrom-PrintableRepr `'" + (ConvertTo-PrintableRepr $args[1..($args.length-1)]) + "`')`n"
    } else {
        $commandString += "`$arglist = @()`n"
    }

    $commandString += $runnerString + "`n"
    Write-Debug $commandString
    $inPipe = new-object IO.Pipes.NamedPipeServerStream $pipeName, "In"
    $psi = new-object System.Diagnostics.ProcessStartInfo
    $psi.FileName = "powershell.exe"
    $psi.Verb = "Runas"
    if ($env:INVOKEASADMINDEBUG) {
        $psi.Arguments = "-NoExit", "-EncodedCommand", (Get-Base64String $commandString)
    } else {
        $psi.WindowStyle = "Hidden"
        $psi.Arguments = "-EncodedCommand", (Get-Base64String $commandString)
    }

    $process = [System.Diagnostics.Process]::Start($psi)
    $inPipe.WaitForConnection()
    try {
        for (;;) {
            $type = $inPipe.ReadByte()
            if ($type -eq 0) {
                break
            }

            $obj = $formatter.Deserialize($inPipe)
            if ($obj -is [System.Management.Automation.ErrorRecord] -or $obj -is [Exception]) {
                Write-Error $obj
            }
            else {
                $obj
            }

        }

    }

    finally {
        $inPipe.Close()
    }
}
