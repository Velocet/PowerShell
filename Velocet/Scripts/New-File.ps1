function New-File {
  <#
    .SYNOPSIS
    Creates a new file like 'touch' from Linux.

    .DESCRIPTION
    Creates a one or more empty files. Overwriting files could be turned on by using the '-Force' parameter.

    .PARAMETER File
    The file or files you want to create.
    
    Seperate files with a comma: file1,file2

    .PARAMETER Force
    Overwrite existing file.

    .EXAMPLE
    New-File -File file1.txt
    Create file1.txt if the file does not exist.

    .EXAMPLE
    New-File -File file1.txt,file2.txt -Force
    Create 'file1.txt' and 'file2.txt'. Overwrite existing files.

    .NOTES
    Accepts pipeline input.

    .LINK
    https://GitHub.com/Velocet/PowerShell

    .INPUTS
    System.String[]
  #>

  Param
  (
    [parameter(
        Mandatory,
        ValueFromPipeline,
        ValueFromPipelineByPropertyName,
        ValueFromRemainingArguments,
        HelpMessage='Provide at least one valid file name. Use a comma to seperate:'
    )]
    [ValidateScript({
          if ($_.IndexOfAny([IO.Path]::GetInvalidFileNameChars()) -ge 0) { $false }
          else { $true }
    })]
    [string[]]$File,
    
    [switch]$Force = $false
  ) 

  foreach ($Item in $File)
  {
    if( ((Test-Path -Path $Item) -and $Force) -or (!(Test-Path -Path $Item)) )
    {
      Write-Output -InputObject $null > $Item

    } # Check if file exists and overwrite if -Force parameter is used    
    else
    {
      Write-Warning -Message 'File exists! Use the -Force parameter to overwrite.'      
    }
  }
} # Linux like touch-Command