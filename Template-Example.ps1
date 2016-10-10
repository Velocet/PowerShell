<# - How To Use -

    Everything starting with a $ sign is to be read as a variable.
    '' translates to a command that isn't a variable and doesn't get expanded.
    "" translates to commands or variables that either act as a placeholder or a variable.
    Variable names are always 'Camel Case' without anything between the nouns or verbs: $VerbNoun
    Variable names that begin with a lowercase describe the type of the variable: $array, $element, $item
    Function names are always 'Camel Case' with a hypen between the verb and the noun.
    For a list of verbs see: Get-Verb | Sort-Object -Property Verb
    If the name is ending with a '1' then the statement could be used many times.

    A comment has a blank character before it starts to distinguish it from a command that is commented out.
    # $Comment.
    
    Multi-line block comments are used when the comment(s) exceeds too much characters per line or if a better formatting is needed (eg. for tables). $MultiLlineBlockCommentSubject is a short topic description to know whats inside the multi-block line comment when it's collapsed.
    <# $MultiLlineBlockCommentSubject
    $MultiLlineBlockComment.
    ($MultiLlineBlockComment.)
    $SharpCharacter># $MultiLlineBlockCommentSubject

    Comments which relate to the command or script block underneath. Script blocks that contain related commands don't have a new line between the commands. This doesn't applie to the requires region.
    # $Comment.
    $Command

    Command could be uncommented and used either in the script or as a seperate command.
    #$Command (# $Command related note.)

    A script block is used when commands are related. Maximum five lines expect for variables.
    $Command
    $Command

    Regions are used to encapsulate commands/a command or script block with optional comment(s) or comment block(s).
    The '#endregion $Name' is also set for better readability.
    #region $Name
    $Command / $ScriptBlock / $Comment(s) / $MultiLlineBlockComment
    ($Command / $ScriptBlock / $Comment(s) / $MultiLlineBlockComment)
    #endregion $Name

    Defines a data type like 'String' or 'Int'.
    [$DataType]

    Always use a comment behind the last bracket of a condition (eg. 'foreach', 'while', 'if', etc.)
    which describes in short words what is going on inside.
    If the condition gets collapsed it is easier to know what is going on inside
    and you don't waste space for a comment that is above the condition.
    A comment above the condition should only be used to describe  what the specific condition in the next line is testing.
    $Condition (<Test>) { $Command / $ScriptBlock } # $WhatIsItDoing

    Brackets do or stand for what is written inside them.
    <$Word1>
    
#># - How To Use -
<# ToDo
    TryCatch Block aus Process raus und um Beginn/Process/End
    http://community.idera.com/powershell/powershell_com_featured_blogs/
#># ToDo

<# Performance
    Einarbeiten: http://community.idera.com/powershell/powertips/b/tips/posts/pretty-printing-error-objects
    Beispiel Template erstellen das SystemDrive rekursiv durchgeht (für jedes Verzeichnis im Root soll ein Thread gestartet werden),
    ausgabe in textdatei speichern, nach string suchen (mehrere threads) und in datei wegspeichern
    http://www.msxfaq.de/code/powershell/psperformance.htm
    https://thesurlyadmin.com/category/powershell/powershell-performance/
    http://windowsitpro.com/scripting/tips-optimizing-powershell-scripts
    https://blogs.technet.microsoft.com/heyscriptingguy/2015/03/13/optimize-powershell-code/
    http://occasionalutility.blogspot.de/2013/09/top-5-powershell-performance-tips.html
    https://powershell.org/2013/09/16/powershell-performance-the-operator-and-when-to-avoid-it/
    https://social.technet.microsoft.com/wiki/contents/articles/11311.powershell-optimization-and-performance-testing.aspx
    https://blogs.technet.microsoft.com/heyscriptingguy/2015/03/13/optimize-powershell-code/
    http://www.jonathanmedd.net/2011/09/powershell-v3-creating-objects-with-pscustomobject-its-fast.html

    Use:
    $Files | Add-Member -MemberType ScriptProperty -Name MB -Value { [math]::Round($this.Length / 1MB,2) } -PassThru | Add-Member -MemberType ScriptProperty -Name GB -Value { [math]::Round($this.Length / 1GB,2) }
    instead of:
    $Files | Select Fullname,Length,@{Name="MB";Expression={[math]::Round($_.Length/1MB,2)}},@{Name="GB";Expression={[math]::Round($_.Length/1GB,2)}}

    #In PowerShell 4.0+ arrays have the methods .Where() and .foreach() a faster alternative to a traditional pipeline at the expense of a higher memory consumption:
    @(Get-Service).Where{$_.Status -eq 'stopped'}
    Build PSObject the fast way: $Folders = foreach ($Folder in (gci 'C:\Windows' -Recurse -Directory)){New-Object PSObject -Property @{Name = $Folder.FullName; Created = $Folder.CreationTime}}
    Use $null instead of | Out-Null
    Avoid '+='! Use Redirect where applicable
    Arrays: Use [array]::$method() where applicable
    Use -NoProfile when executing PS scripts: powershell.exe -NoProfile –File 'Script.ps1'
    Use RegEx:
    [regex]$Search="^.{5}$"; Get-Content $path | Where {$_ -match $Search} | % {$Count++}
    Instead of:
    Get-Content $path | Where {$_.Length -eq 5 } | % {$Count++}
    Use Inline-RegEx:
    Get-Content $path | Where {$_ -match "^.{5}$"} | % {$Count++}
    Instead of:
    [regex]$Search="^.{5}$"; Get-Content $path | Where {$_ -match $Search} | % {$Count++}
    Use $ObjectAttribute = $Object.Attribute;$ObjectAttribute instead of $Object.Attribute if accessing the variable more than once
    Use foreach over foreach-Object
    Arrays vs HashTables:
    0..999 | % {$array+=New-Object PSObject -Property @{Key=$dic[$_];WordNumber=$_}}
    0..999 | % {$TestHash.Add($dic[$_],$_)} #much faster
    Use Methods when they are available: Where, foreach, ... http://ss64.com/ps/foreach-method.html
    Arrays: http://ss64.com/ps/syntax-arrays.html
    Use Generic Lists instead of Array Lists: https://gist.github.com/IISResetMe/3facb38f97126253c276147b2c8f5202
    New Array: $a = New-Object System.Collections.ArrayList
    foreach: Use GetEnumerator() :foreach($element in $array.GetEnumerator()){$sum+=$element}
    Files (Get-Content): .NET StreamReader: http://ss64.com/ps/get-content.html or .NET.File.WriteLine / .NET.StreamWriter.WriteLine
    Strings: .NET StringBuilder http://ss64.com/ps/syntax-variables.html
    Search (Array Filtering/Compare): Use HashTables - https://gist.github.com/IISResetMe/b21a6f0629a10c83eadf
    Where-Object > Where > .Where() > filter > foreach : https://powershell.org/2013/11/17/powershell-performance-filtering-collections/
    Get-Content: Get-Content with '-ReadCount 0' really makes only sense when you plan not to use the PowerShell pipeline to process the data!
    Use foreach : foreach($line in (Get-Content $env:windir\windowsupdate.log -ReadCount 0)){if($line -like '*successfully installed*'){$line}}
    Multithreading: https://github.com/proxb/PoshRSJob
    Use Enums (PS > 5): http://community.idera.com/powershell/powertips/b/tips/posts/using-enumerations
    http://community.idera.com/powershell/powertips/b/tips/posts/better-prompting-for-mandatory-parameters
    Abfragen so gut es geht einschränken
    Use Filter where Methods() are not available
    Always use positional parameter
    Use:
    foreach($item in (Get-ChildItem 'C:\' -Recurse)){$ScriptBlock}
    instead of:
    Get-ChildItem 'C:\' -Recurse | foreach{$ScriptBlock}
    Get-Content done right: https://thesurlyadmin.com/2015/06/01/read-text-files-faster-than-get-content/
#># Performance

<# Best Practics
    https://ramblingcookiemonster.wordpress.com/2013/12/08/building-powershell-functions-best-practices/
    https://blogs.technet.microsoft.com/pstips/2014/06/17/powershell-scripting-best-practices/
    Always .Dispose() your threads
#># Best Practices

#region Requires

<# Requires

    Prevent script from running without required elements
    #Get-Help about_Requires

#> # Reguires

#Requires -ShellId Microsoft.PowerShell
#Requires -RunAsAdministrator
#Requires -Version 4

#endregion Requires

#region Help

<# PowerShell Usage

    # Basic Get-Help topics:
    about_Language_Keywords

    about_Special_Characters
    about_Escape_Characters

    about_Here-Strings
    about_Quotes
    about_Quotation_Marks
    about_Escape_Characters

#> # PowerShell Usage

<# Basics

    # Path Syntax (about_path_syntax) - Full and relative path name formats

    # Providers - Access data and components in a file system format
    Get-PsProvider # List providers
    # List Standard Providers Values:
    Get-ChildItem Alias:    # Aliases, same as 'Alias'
    Get-ChildItem Cert:     # x509 certificates for digital signatures
    Get-ChildItem HKLM:     # Registry: HKEY_LOCAL_MACHINE
    Get-ChildItem HKCU:     # Registry: HKEY_CURRENT_USER
    Get-ChildItem Function: # Functions the user can access
    Get-ChildItem Variable: # Variables, same as 'Get-Variable'
    Get-ChildItem WSman:    # WS-Management configuration information

    # Scopes (about_Scopes) - Concept of scope in PowerShell and how to set it
    Get-Help * -Parameter Scope # List session cmdlets with a scope parameter
    Get-Variable -Scope $scope # List items in a particular scope

    # Modules (about_Modules) - Install, import, and use modules

    # Parameters (about_Parameters)
    Get-Help -Name $Command -Parameter * # info about all parameters of "$command"
    # Default Parameters (about_Parameters_Default_Values) - Defaults set by user/script
    $PSDefaultParameterValues # List default parameters

#> # Basics

<# Variables (about_Variables)

    To list all available data types which a variable could become use this command:
    [AppDomain]::CurrentDomain.GetAssemblies() | % { $_.GetExportedTypes().FullName }

    ISE/PoSh supports aliases for some of data types. These aliases are called "Type Accelerators":
    [PSObject].Assembly.GetType('System.Management.Automation.TypeAccelerators')::Get

    # Preference Variables (about_Preference_Variables) - PowerShell behavior

    Variable                             Default                   Options
    --------                             -------                   -------
    $ConfirmPreference                   High
    $DebugPreference                     SilentlyContinue
    $ErrorActionPreference               Continue
    $ErrorView                           NormalView
    $FormatEnumerationLimit              4
    $InformationPreference               SilentlyContinue
    $LogCommandHealthEvent               False (not logged)
    $LogCommandLifecycleEvent            False (not logged)
    $LogEngineHealthEvent                True (logged)
    $LogEngineLifecycleEvent             True (logged)
    $LogProviderLifecycleEvent           True (logged)
    $LogProviderHealthEvent              True (logged)
    $MaximumAliasCount                   4096
    $MaximumDriveCount                   4096
    $MaximumErrorCount                   256
    $MaximumFunctionCount                4096
    $MaximumHistoryCount                 4096
    $MaximumVariableCount                4096
    $OFS                                 (Space character (" "))
    $OutputEncoding                      ASCIIEncoding object
    $ProgressPreference                  Continue
    $PSDefaultParameterValues            (None - empty hash table)     
    $PSEmailServer                       (None)
    $PSModuleAutoLoadingPreference       All
    $PSSessionApplicationName            WSMAN
    $PSSessionConfigurationName          http://schemas....
    $PSSessionOption                     (See below)
    $VerbosePreference                   SilentlyContinue
    $WarningPreference                   Continue
    $WhatIfPreference                    0

    # User Preference Variables (about_Environment_Variables) - PowerShell behavior

    User Preference Variable       Default
    ------------------------       -------
    $PSExecutionPolicyPreference   (None)
    $PSModulePath                  (None)

    # Enviroment Variables (about_Environment_Variables) - Windows environment variables
    Get-ChildItem Env: # List Windows environment variables

    # Automatic Variables (about_Automatic_Variables) - Store state information maintained by PowerShell

    Automatic Variable   Contains
    ------------------   --------
    $$                   Last token in the last line received.
    $?                   Last execution status: TRUE / FALSE.
    $^                   First token in the last line received.
    $_                   Pipeline object (same as "$PSItem").
    $AllNodes            Config data when passed by using '-ConfigurationData'.
    $Args                Passed parameters and/or parameter values.
    $ConsoleFileName     Recently used console file (.psc1).
    $Error               Most recent errors.
    $Event               Processed Event.
    $EventArgs           First argument that derives from "$EventArgs".
    $EventSubscriber     Event subscriber.
    $ExecutionContext    Execution context of the host.
    $False               Contains FALSE.
    $foreach             Enumerator (not the values) of a foreach loop.
    $Home                User home dir.
    $Host                Host application.
    $Input               Enumerates all input that is passed.
    $LastExitCode        Last run Windows-based program exit code.
    $Matches             Boolean value if match detected (-match/-notmatch).
    $MyInvocation        Command info: Invoker/calling script, not current script.
    $NestedPromptLevel   Prompt level.
    $NULL                NULL or empty value.
    $OFS                 Output field separator.
    $PID                 Process identifier (PID).
    $Profile             PoSh user profile path.
    $PSBoundParameters   Passed parameters and values.
    $PsCmdlet            Cmdlet/Function that is run. 
    $PSCommandPath       Path of script that is run.
    $PsCulture           Culture currently in use in the OS.
    $PSDebugContext      Debugging environment information.
    $PsHome              PoSh installation dir.
    $PSItem              Current pipeline object (same as $_).
    $PSScriptRoot        Dir from which script is run. 
    $PSSenderInfo        User that started the "$PSSession".
    $PsUICulture         UI culture name.
    $PsVersionTable      PoSh version infos.
    $Pwd                 Current dir.
    $Sender              Object that generated this event.
    $ShellID             Current shell indentifier.
    $StackTrace          Recent error stack trace.
    $This                Object that is being extended.
    $True                Contains TRUE.

#> # Variables

#endregion Help

#region ================== [ INITIALISATIONS & DECLARATIONS] ==================

#region Stopwatch

$StopWatch = [Diagnostics.Stopwatch]::StartNew()
$StopWatch_ms = $StopWatch.ElapsedMilliseconds
$StopWatch_ticks = $StopWatch.ElapsedTicks

#endregion Stopwatch

<#
    Turns script debugging features on or off,
    sets the trace level, and toggles strict mode.
#>
Set-PSDebug -Off

<#
    Determines the coding rules that will be enforced for the script's scope,
    and anything beneath it. 'Latest' setting ignores shell versions,
    opting for the 'best' (most strict) practices.
    Don't forget to turn it off at the end of the script!
#>
Set-StrictMode -Version Latest

$ExternalScriptPath = [String] # Path to dir that holds our external script(s)
# Check if $ExternalScriptPath path exists
if(Test-Path -Path ($ExternalScriptPath)) {
  . "$ExternalScriptPath\ExternalScript1.ps1"
  Import-Module -Name "$ExternalScriptPath\Module1"
} # Load external scripts and modules

# By default, variables are available only in the scope in which they are created. Use a scope modifier to change the default scope.
[scope_type:]$VariableName = <Value>
[ValidateSet('1','2','3')][int]$<Variable> = '1' # Works
[ValidateSet('1','2','3')][int]$<Variable> = '4' # Works not


#endregion ------------------ initialisations & declarations ------------------

#region ============================ [ FUNCTIONS ] ============================

# By default, functions are available only in the scope in which they are created. Use a scope modifier to change the default scope.
#Get-Help about_Functions
#Get-Help about_Functions_Advanced               # Advanced functions use the 'CmdletBinding' attribute to act like cmdlets.
#Get-Help about_Functions_Advanced_Methods       # How to use methods and properties available to cmdlets in functions. 
function [scope_type:]<Verb>-<Noun> {

  #region Comment Based Help

  # Exported functions should have comment-based help texts for 'Get-Help'.
  #Get-Help about_Comment_Based_Help # How to write comment-based help

  <# Comment Based Help

      .SYNOPSIS
      A brief description of the function or script.

      .DESCRIPTION
      A detailed description of the function or script.

      .PARAMETER <Parameter_Name>
      The description of a parameter.

      .INPUTS
      .NET objects that can be piped to the function or script.

      .OUTPUTS
      .NET objects that the function or script returns.

      .NOTES
      Additional information about the function or script.
      Author:         $env:username
      Company:        $company
      Version:        0.0.0 (see https://semver.org)
      Release Date:   YYYY-MM-DD (see https://www.iso.org/iso/home/standards/iso8601.htm)
      Purpose/Change: Initial version
      License:        $license (see https://opensource.org/licenses or http://choosealicense.com/)
      License-Link:   https://domain.tld/licenses
      Copyright:      2016, $env:username
      Copyright-Link: https://domain.tld/copyright

      .LINK
      https://domain.tld
      First link is opened by Get-Help -Online FUNCTION
      
      .EXAMPLE
      Sample command that uses the function or script, optionally followed by sample output and a description.

      .COMPONENT
      Technology or feature that the function or script uses, or to which it is related.

      .ROLE
      User role for the help topic.

      .FUNCTIONALITY
      Intended use of the function. Appears when Get-Help FUNCTION -Functionality parameter called.

      .FORWARDHELPTARGETNAME <Command-Name>
      Redirects to the help topic for the specified command.

      .FORWARDHELPCATEGORY  <Category>
      Specifies the help category of the item in ForwardHelpTargetName.

      .REMOTEHELPRUNSPACE <PSSession-variable>
      Specifies a session that contains the help topic.

  #> # Comment Based Help

  #endregion Comment Based Help
  
  # Advanced PowerShell functions contain the [cmdletbinding()] attribute. This adds several capabilities such as additional parameter checking, the ability to easily use Write-Verbose and will throw an error if unhandled parameter values appear.
  #Get-Help about_Functions_CmdletBindingAttribute # Attribute that makes a function work like a cmdlet.
  [CmdletBinding(
      ConfirmImpact=<String>,
      DefaultParameterSetName=<String>,
      HelpURI=<URI>,
      SupportsPaging=<Boolean>,
      SupportsShouldProcess=<Boolean>,
      PositionalBinding=<Boolean>
  )] # CmdletBinding

  #Get-Help about_Functions_OutputTypeAttribute    # Report the type the function returns.
  [OutputType([[$DataType]], ParameterSetName="ParameterSetName1")] # Perform different tasks with parameter sets based on the parameters that are specified when the function is run.

  #Get-Help about_Functions_Advanced_Parameters    # How to add parameters to advanced functions.  
  param(
    # Description of the parameter that gets shown when Get-Help is called
    [Parameter(
        Mandatory=[$Boolean],
        Position=[$Int],
        ParameterSetName=$ParameterSetName1,
        ValueFromPipeline=[$Boolean],
        ValueFromPipelineByPropertyName=[$Boolean],
        ValueFromRemainingArguments=[$Boolean],
        HelpMessage=$HelpMessage
    )]
    [Alias('$Alias1')]
    [AllowNull()]
    [AllowEmptyString()]
    [AllowEmptyCollection()]
    [ValidateCount([Int],[Int])]
    [ValidateLength([Int],[Int])]
    [ValidatePattern("[$RegEx]")]
    [[$DataType]]$Parameter1                            # or set the parameter: [String]$Parameter1 = 'Parameter1'
  ) # Defines (or limits) the parameter values that function users submit with the parameter.

  DynamicParam {
    if (<Test1>) {
      $Attributes = new-object System.Management.Automation.ParameterAttribute
      $Attributes.ParameterSetName = "__AllParameterSets"
      $Attributes.Mandatory = $false
      $AttributeCollection = new-object -Type System.Collections.ObjectModel.Collection[System.Attribute]
      $AttributeCollection.Add($Attributes)

      $DynamicParam1 = new-object -Type System.Management.Automation.RuntimeDefinedParameter("DynamicParam1", [Int32], $AttributeCollection)
            
      $ParamDictionary = new-object -Type System.Management.Automation.RuntimeDefinedParameterDictionary
      $ParamDictionary.Add("DynamicParam1", $DynamicParam1)
      return $ParamDictionary
    } 
  } # Create dynamic parameter only when condition is met.
  
  begin {
    # Cancel execution if error occurs per function
    $ErrorActionPreference = 'Stop'    
    $ConfirmPreference = 'High'
    $VerbosePreference = 'SilentlyContinue' # Set verbose output per function
    if($VerbosePreference -ne 'SilentlyContinue') {
      # Stopwatch
      $StopWatch = [diagnostics.stopwatch]::StartNew()
      $StopWatch_ms = $StopWatch.ElapsedMilliseconds
      $StopWatch_ticks = $StopWatch.ElapsedTicks
      
      $fname = $MyInvocation.MyCommand.Name
      Write-Verbose -Message "[BEGIN] Execution of Function: $fname"
    } # Set the stop watch and other settings if verbose is on
  } # Runs one time before any objects are received from the pipeline.
  
  process {

    try {

      trap {

        <#
            The Trap statement handles terminating errors and allows the execution
            of the script or function to continue instead of stopping like a normal try/catch-block.
            Put the trap block at the beginning of the function or try statement.
            Define what you want to do after a error ocurred: 'continue' or 'break'
        #>
        
        $ScriptBlock

        #continue

      }
      
      trap [$SpecificException] {
        <#
            Catch specific exceptions for custom actions of different types of errors.
        #>

        $ScriptBlock

        #continue
                      
      }
      
      <#
          Add dangerous code here that might produce exceptions.
          Place as many code statements as needed here.
          Non-terminating errors must have error action preference set to Stop to be caught.
      #>

    }

    catch [$SpecificException] {
      <#
          Catch specific exceptions for custom actions of different types of errors.
      #>
      Write-Error '[EXCEPTION] Caught ItemNotFoundException!'
    }
    
    catch {
      <#
          You can have multiple catch blocks (see above), or one single catch.
          Last error record is available inside catch block under the $_ variable.
          Code inside this block is used for error handling like logging an error,
          sending an E-Mail, writing to the event log, performing a recovery action, etc.
      #>
      Write-Error "[EXCEPTION] Invokation: $($_.InvocationInfo)"
      Write-Error "[EXCEPTION] Type: $($_.Exception.GetType().FullName)"
      Write-Error "[EXCEPTION] Message: $($_.Exception.Message)"
      #Write-Error "StackTrace: $($_.Exception.StackTrace)"
    }

    finally {
      <#
          Statements in this block will always run even if errors are caught.
          This statement block is optional and is normally used for cleanup and/or
          releasing resources that must happen even under error situations.
      #>
      Write-Output -Message "[RUNTIME] $($($StopWatch.ElapsedTicks)-$StopWatch_ticks) ticks ($($($StopWatch.ElapsedMilliseconds)-$StopWatch_ms) ms)"
    }

  } # Process once for every input given (eg. gets executed for every pipeline input).

  end {
    if($VerbosePreference -ne 'SilentlyContinue') {
      Write-Verbose -Message "[RUNTIME] $($($StopWatch.ElapsedTicks)-$StopWatch_ticks)ticks ($($($StopWatch.ElapsedMilliseconds)-$StopWatch_ms)ms)"
      $StopWatch.Stop()
      Write-Verbose -Message "[END] Execution of Function: $fname"
    } # Write the execution time of the function and set other settings if verbose is on
  } # Runs one time after all the objects have been received from the pipeline.

} # What is the function doing?

#endregion ---------------------------- functions -----------------------------

#region ============================== [SCRIPT] ===============================

# Here goes the script that executes the above functions, calls variables, etc.

Set-StrictMode -Off

#endregion ------------------------------ script ------------------------------