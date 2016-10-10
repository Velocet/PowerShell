# Microsoft Windows Powershell Module Script
#
# Name: PSSpeak
# Version: 0.0.0.2
# Author: Michal Millar
# https://github.com/michalmillar
# http://www.bolis.com
#
# License: 
# The BSD 3-Clause License
# Copyright (c) 2016, The Bolis Group
#
# Description:
# Outputs text as spoken words. 
#

# The Strictmode setting determines what coding rules will be enforced for the
# script's scope, and anything beneath it. The "Latest" setting ignores shell
# versions, opting for the best (most strict) practices.
Set-StrictMode -Version Latest

# Each function block intended to be exported as a command-object should have
# a block of synopsis information. This can then be used by `Get-Help` as the
# short-form basis for man-like help text.
<#
.SYNOPSIS
    Outputs text as spoken words.
.DESCRIPTION
    Outputs text as spoken words.
.PARAMETER InputObject
    One or more string-values to speak.
.PARAMETER File
    Specifies that the InputObject is a file and the contents should be spoken.
.PARAMETER XML
    Read the contents of the XML file indicated.
.PARAMETER Wait
    Wait for the machine to read each item before continuing.
.PARAMETER Purge
    Remove all speech requests before the current command.
.EXAMPLE
    \\PS> Out-Speak "Hello World"
    Speaks "hello world".
.EXAMPLE
    \\PS> Get-Content Foo_Bar.txt | Get-Random | Out-Speak -Wait
    Speaks a random line from a file.
.EXAMPLE
    \\PS> Out-Speak -FilePath ".\Foo_Bar.txt"
    Speaks the entire contents of a file.
.NOTES
#>
Function Out-Speak {
    [CmdletBinding()] 
    Param(
        [Parameter(Position=0,
        Mandatory=$True,
        ValueFromPipeline=$True)]
        [PSObject[]]$InputObject,
        [Switch]$File,
        [Switch]$XML,
        [Switch]$Wait,
        [Switch]$Purge
    )
     
    Begin {  
        # To override this default, use the other flag values given below.
        # Specifies that the default settings should be used.  
        Set-Variable -Name Flag_Default -Value 0  

        # To override this default, use the other flags given below.
        # The defaults are:
        # - Speak the given text string in order (synchronously)
        # - Queue pending speak requests
        # - Parse the text as XML only if the first character is a left-angle
        #   bracket (<)

        # Specifies that the string is a file and the contents should be spoken.
        Set-Variable -Name Flag_File -Value 4
        # Specifies that the string is an XML file.
        Set-Variable -Name Flag_XML -Value 8 
        # Specifies that the speak command should be run asynchronously.
        Set-Variable -Name Flag_Async -Value 1
        # Remove all speech requests before the current command.
        Set-Variable -Name Flag_Purge -Value 2
        
        Set-Variable -Name Speech_Flag -Value ${Flag_Default}

        if (${File}) {
            ${Speech_Flag} += ${Flag_File}
        }
        if (${XML}) {
            ${Speech_Flag} += ${Flag_XML}
        }
        If (!${Wait}) {
            ${Speech_Flag} += ${Flag_Async} 
        }
        if (${Purge}) {
            ${Speech_Flag} += ${Flag_Purge}
        }

        Set-Variable -Name Voice -Value $(New-Object -Com SAPI.SpVoice)
    }
     
    Process {
        Foreach ($obj in ${InputObject}) {
            $str = $obj | Out-String
            $exit = $Voice.Speak($str, ${Speech_Flag})
        }
    }

    End {}
}

New-Alias -Name Say -Value Out-Speak

Export-ModuleMember -Function Out-Speak -Alias Say
