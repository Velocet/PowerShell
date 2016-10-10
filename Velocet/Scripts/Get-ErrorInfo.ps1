function Get-ErrorInfo
{
  <#
      .SYNOPSIS
      Formatted error output.

      .DESCRIPTION
      Creates a formatted output for the last errors that happend.

      .NOTES
      Could be used in a script.

      .LINK
      https://GitHub.com/Velocet/PowerShell
  #>
  
  param(
    [Parameter(Mandatory, ValueFromPipeline)]
    [Management.Automation.ErrorRecord]
    $ErrorInfo
  )

  process
  {
    $hash = [Ordered]@{
      Script   = $ErrorInfo.InvocationInfo.ScriptName
      Message  = $ErrorInfo.Exception.Message
      Line     = "$($ErrorInfo.InvocationInfo.ScriptLineNumber) @ Column $($ErrorInfo.InvocationInfo.OffsetInLine)"
      Category = "$($ErrorInfo.CategoryInfo.Reason) @ $($ErrorInfo.CategoryInfo.Category)"
      Target   = $ErrorInfo.CategoryInfo.TargetName
      Stack    = $ErrorInfo.Exception.StackTrace
    }

    New-Object -TypeName PSObject -Property $hash
  }
}