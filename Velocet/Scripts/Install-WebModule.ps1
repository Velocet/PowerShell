function Install-WebModule {
  <#
      .SYNOPSIS
      Download and install a module file from a web location.

      .DESCRIPTION
      Downloads a module file from the internet, installs it and then imports it.

      .PARAMETER Uri
      URI of the module file to download.

      .PARAMETER ModuleName
      Name of the module which is used for creating the folder in which the module gets installed.
      
      Should not contain any hypens oder underscores.
      
      .PARAMETER Private
      If this switch is provided the module gets installed inside the users private modules folder.

      This is good if you are not on your system and want to remove your profile including all modules you used after leaving.

      .EXAMPLE
      Install-WebModule -Uri 'https://domain.tld/module.psm1' -ModuleName 'ModuleName'

      Downloads module.psm1 inside $Profile part of $PSModulePath and then installs and imports it.

      .EXAMPLE
      Install-WebModule -Uri 'https://domain.tld/module.psm1' -ModuleName 'ModuleName' -Private

      Downloads module.psm1 in the 'Modules\$ModuleName' in $env:UserName in the $Profile. Then installs and imports it.

      This is good if you are not on your system and want to remove your profile including all modules you used after leaving.

      .LINK
      https://GitHub.com/Velocet/PowerShell

      .NOTES
      Don't mind your make-up. Make your mind up!
  #>
  
  Param (
    [parameter(
        Mandatory,ValueFromPipeline,ValueFromPipelineByPropertyName,
        HelpMessage='Module URI.'
    )]
    [string]$Uri,

    [parameter(
        Mandatory,ValueFromPipeline,ValueFromPipelineByPropertyName,
        HelpMessage='Module name used for the module folder.'
    )]
    [alias('Module')]
    [string]$ModuleName,
        
    [switch]$Private=$false
  )

  Process {

    try {
      $ModuleFile = Split-Path -Path $Uri -Leaf                            # Downloaded module file name
      $ModulePath = Split-Path -Path $profile -Parent                      # Get path part of $profile
      if ($Private) {                                                      # If private option is used:
      $ModulePath = Join-Path -Path $ModulePath -ChildPath $env:USERNAME } # Add user name to module folder path
      $ModulePath = Join-Path -Path $ModulePath -ChildPath 'Modules'       # Add 'Modules' to the module folder path
      $ModulePath = Join-Path -Path $ModulePath -ChildPath $ModuleName     # Add given module name to module folder path      
      $Module     = Join-Path -Path $ModulePath -ChildPath $ModuleFile     # Generate module path

      
      # Create module folder based on the provided $ModuleName
      New-Item -Path $ModulePath -ItemType Directory -Force

      # Download Module
      Invoke-WebRequest -Uri $Uri -OutFile $Module

      # Install Module
      Install-Module -Module $Module

      # Import Module
      Import-Module -Name $ModuleName
      
      # Output module info
      Get-Module -Name $ModuleName -ListAvailable
      
      # Output imported module commands
      Get-Command -Module PoshCode -ListImported
    }
    
    catch { Write-Error -Message $_ }
  }
}