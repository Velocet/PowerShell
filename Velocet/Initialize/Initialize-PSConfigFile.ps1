function Sript:Initialize-PSConfigFile {
  param([string][Parameter(Mandatory,HelpMessage='Config File Path')]$Path)
  function Add-PrincipalNode {
    param([String][Parameter(Mandatory)]$AttributeName,[String][Parameter(Mandatory)]$AttributeValue)
    $xmlAtt = $xmlDoc.CreateAttribute($AttributeName)
    $xmlAtt.Value = $AttributeValue
    $xmlElt.Attributes.Append($xmlAtt)
  } # Create attribute in principal node
  function Add-SubNode {
    param([String][Parameter(Mandatory)]$ElementName,[String][Parameter(Mandatory)]$ElementValue)
    $xmlSubElt = $xmlDoc.CreateElement($ElementName)
    $xmlSubText = $xmlDoc.CreateTextNode($ElementValue)
    $xmlSubElt.AppendChild($xmlSubText)
    $xmlElt.AppendChild($xmlSubElt)
  }       # Create sub node  

  # Create XML
  [xml]$xmlDoc = New-Object System.Xml.XmlDocument
  $xmlDoc.LoadXml('<?xml version="1.0" encoding="UTF-8"?><Settings></Settings>')
  
  # Create node and its text
  $xmlElt = $xmlDoc.CreateElement('Host')
  Add-PrincipalNode -AttributeName 'Name' -AttributeValue $env:COMPUTERNAME
  
  # Create Sub Nodes
  Add-SubNode -ElementName 'Date' -ElementValue $(Get-Date -Format yyyy-MM-dd)
  Add-SubNode -ElementName 'PowerShell' -ElementValue $true
  Add-SubNode -ElementName 'PackageManager' -ElementValue $true
  
  # Add the nodes to the document
  $xmlDoc.LastChild.AppendChild($xmlElt)

  # Save to a file 
  $xmlDoc.Save($Path)
} # Create XML config

# Only run if script is invoked from another script
if ($MyInvocation.PSCommandPath)
{
  Write-Verbose "      File: $PSCommandPath"
  Write-Verbose "Invocation: $($MyInvocation.PSCommandPath)"
  
  # Invoking script: Config file path
  $PSProfileConfig = $MyInvocation.PSCommandPath + '.xml'
  if($args) {
    Write-Verbose "     Using: $($args[0])"
    $PSProfileConfig = $args[0]
  } # Use given argument instead of invoked file path

  if (!(Test-Path -Path $PSProfileConfig)) {
    Write-Verbose "  Creating: $PSProfileConfig"
    Initialize-PSConfigFile -Path $PSProfileConfig
  }  
}