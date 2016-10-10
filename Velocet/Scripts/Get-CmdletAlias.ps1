function Get-CmdletAlias
{
  <#
      .SYNOPSIS
      Get alias(es) for a Cmdlet.

      .DESCRIPTION
      Get alias(es) for a Cmdlet.

      .PARAMETER Cmdlet
      The Cmdlet for which you want the alias(es).

      .EXAMPLE
      Get-CmdletAlias Get-Help
      Gets the alias(es) for 'Get-Help'

      .LINK
      https://GitHub.com/Velocet/PowerShell

      .INPUTS
      System.String
  #>

  Param
  (
    [parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName, ValueFromRemainingArguments, HelpMessage='Provide a Cmdlet:')]
    [string]$Cmdlet
  ) 
  
  @(Get-Alias).Where{$_.Definition -like "*$Cmdlet*"} | Select-Object -Property Definition, Name
}