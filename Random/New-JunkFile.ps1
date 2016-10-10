function New-JunkFile
{
<#
.SYNOPSIS
    Generates a file of a specified length, filled with random bytes

.DESCRIPTION
    Generates a file of a specified length, filled with random bytes
    Uses the RNGCryptoServiceProvider to randomly select each byte

.PARAMETER Length
    The Length of the file to generate, in bytes

.PARAMETER Path
    The Path to the file to create, file will be overwritten if it already exists

.PARAMETER ShowProgress
    Displays a progress bar with the progress of the current operation

.EXAMPLE
    New-JunkFile -Length 20mb -Path C:\TestJunk.dat


    Directory: C:\


Mode                LastWriteTime         Length Name
----                -------------         ------ ----
-a----        5/19/2015  10:13 PM       20971520 TestJunk.dat
#>
    param(
        [Parameter(Mandatory = $True)]
        [int] $Length,
        [Parameter(Mandatory = $True)]
        [string] $Path,
        [switch] $ShowProgress
    )
    Function Format-FileSize() {
        # From http://superuser.com/a/468795
        Param ([int]$size)
        If     ($size -gt 1TB) {[string]::Format("{0:0.00} TB", $size / 1TB)}
        ElseIf ($size -gt 1GB) {[string]::Format("{0:0.00} GB", $size / 1GB)}
        ElseIf ($size -gt 1MB) {[string]::Format("{0:0.00} MB", $size / 1MB)}
        ElseIf ($size -gt 1KB) {[string]::Format("{0:0.00} kB", $size / 1KB)}
        ElseIf ($size -gt 0)   {[string]::Format("{0:0.00} B", $size)}
        Else                   {""}
    }

    $File = New-Object System.IO.FileStream $Path, Create, ReadWrite
    $File.SetLength($Length)

    $Crypto = New-Object System.Security.Cryptography.RNGCryptoServiceProvider

    if($Length -lt 1kb)
    { $Block = $Length }
    elseif($Length -lt 1mb)
    { $Block = 1kb }
    else
    { $Block = 1mb }
    
    $NumBlocks = ($Length / $Block) - 1
    $UnevenBlock = $false

    if(($Length % $Block) -ne 0)
    {
        $UnevenBlock = $true
        $NumBlocks -= 1
    }

    $FileSize = Format-FileSize -Size $Length

    0..$NumBlocks | ForEach-Object {
        if($ShowProgress.IsPresent)
        {
            $CurrentSize = Format-FileSize -Size ($_ * $Block)
            Write-Progress -PercentComplete (($_ / $NumBlocks) * 100) -Activity "Generating $FileSize Junk File" -Status "$CurrentSize/$FileSize complete"
        }
        $data = New-Object byte[] $Block
        $crypto.GetNonZeroBytes($data)

        $File.Write($data, 0, $Block)
    }

    if($UnevenBlock)
    {
        if($ShowProgress.IsPresent)
        { Write-Progress -Complete }
        $FinalBlock = $Length - ($Block * $NumBlocks)
        $data = New-Object byte[] $FinalBlock
        $crypto.GetNonZeroBytes($data)

        $File.Write($data, 0, $FinalBlock)
    }
    $File.Flush()
    $File.Close()
    Get-ChildItem -Path $Path
}