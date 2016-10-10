#Requires -RunAsAdministrator
#Requires -Version 3.0

function New-NetFirewallAppRule {

    Param(
	    [parameter(Mandatory=$true,HelpMessage = "Directory to be blocked")]
	    [String]$dir,
        [parameter(Mandatory=$true,HelpMessage = "Blocked applications group name")]
	    [String]$group
    )

    begin {
        $ErrorActionPreference = "Stop" #Cancel execution if error occurs
    }

    process {
        
        try {
            # Get executables in $dir recursively
            $files = Get-ChildItem -Path $dir -Recurse -File -Filter *.exe

            # Create outbound rule for every executable in $files
            foreach ($file in $files) {
                $rule = New-NetFirewallRule -Action Block -Direction Outbound -Group $group -DisplayName $file.Name -Program $file.FullName
				Write-Host "Blocked:" $file.FullName
            }
        }
        
        catch {
            Write-Error $("ERROR:" + $_.Exception.GetType().FullName); 
	        Write-Error $("ERROR:" + $_.Exception.Message);            
        }
        
        finally {
            $error.clear()
        }
    }

    end {
        $dir = null
        $group = null
    }
} # Create firewall rules to block executables in the given directory and its sub-directories

# Delete old rules before creating new
Get-NetFirewallApplicationFilter -Program "*\Adobe\*" -PolicyStore ActiveStore | Remove-NetFirewallRule

New-NetFirewallAppRule -dir $("$env:ProgramFiles"+'\Adobe\') -group "Adobe"
New-NetFirewallAppRule -dir $(${env:ProgramFiles(x86)}+'\Adobe') -group "Adobe"