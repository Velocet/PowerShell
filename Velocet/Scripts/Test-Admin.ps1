function Test-Admin {
  <#
      .SYNOPSIS
      Test if the current user has admin rights.

      .DESCRIPTION
      Test if the current user has admin rights. This is done by quering the
      built-in 'Administrators' group via SID 'S-1-5-32-544'.
       
      See Links for further information.

      .INPUTS
      None. You cannot pipe objects to Test-Admin.

      .OUTPUTS
      System.Boolean.

      .EXAMPLE
      Test-Admin
      
      Returns $true if the current user has admin rights and $false it not.

      .EXAMPLE
      if (Test-Admin)
      {
        # Execute script block if User has Administrator privileges
      }

      else
      {
        # Execute script block if User has no Administrator privileges
      }

      .LINK
      https://github.com/Velocet/PowerShell/

      .LINK
      https://msdn.microsoft.com/library/cc980032.aspx - Microsoft Developer Network (MSDN): Well-Known SID Structures
  #>

  return ([Security.Principal.WindowsIdentity]::GetCurrent().Owner.Value -like 'S-1-5-32-544')

} # Return $true if Administrator