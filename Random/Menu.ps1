$Title = "Select OS"
$Message = "What OS is your favorite?"
$WindowsME = New-Object System.Management.Automation.Host.ChoiceDescription "&Windows ME", `
    "Windows ME"
$MacOSX = New-Object System.Management.Automation.Host.ChoiceDescription "&MacOSX", `
    "MacOSX"
$Options = [System.Management.Automation.Host.ChoiceDescription[]]($WindowsME, $MacOSX)
$SelectOS = $host.ui.PromptForChoice($title, $message, $options, 0) 

    switch($SelectOS)
    {
        0 {Write-Host "You love Windows ME!"}
        1 {Write-Host "You must be an Apple fan boy"}
    }