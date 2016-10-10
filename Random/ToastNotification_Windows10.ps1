function New-ToastNotification
{
    param(
        [Parameter(Mandatory=$true)]
        [string]$Title,

        [Parameter(Mandatory=$false)]
        [string[]]$Message,

        [Parameter(Mandatory=$false)]
        [ValidateScript({Test-Path $_ -PathType Leaf})]
        [string]$Thumbnail,

        [Parameter(Mandatory=$false)]
        [Windows.UI.Notifications.ToastTemplateType]$Template = 'ToastText01'
    )
    
    if(-not $PSBoundParameters.ContainsKey('Template'))
    {
        $Template = if($PSBoundParameters.ContainsKey('Thumbnail'))
        {
            if($PSBoundParameters.ContainsKey('Message'))
            {
                if($Message.Count -ge 2)
                {
                    [Windows.UI.Notifications.ToastTemplateType]::ToastImageAndText04
                }
                else
                {
                    [Windows.UI.Notifications.ToastTemplateType]::ToastImageAndText02
                }
            }
            else
            {
                [Windows.UI.Notifications.ToastTemplateType]::ToastImageAndText01
            }
        }
        else
        {
            if($PSBoundParameters.ContainsKey('Message'))
            {
                if($Message.Count -ge 2)
                {
                    [Windows.UI.Notifications.ToastTemplateType]::ToastText04
                }
                else
                {
                    [Windows.UI.Notifications.ToastTemplateType]::ToastText02
                }
            }
            else
            {
                [Windows.UI.Notifications.ToastTemplateType]::ToastText01
            }
        }
    }

    [Windows.UI.Notifications.ToastNotificationManager, Windows.UI.Notifications, ContentType = WindowsRuntime] > $null

    $TemplateContent = [Windows.UI.Notifications.ToastNotificationManager]::GetTemplateContent($Template)

    $toastXml = [xml]$TemplateContent.GetXml()

    $MessageLine1,$MessageLine2,$null = $Message

    if($Node1 = $toastXml.SelectSingleNode('//text[@id = ''1'']'))
    {
        $Node1.AppendChild($toastXml.CreateTextNode($Title)) > $null
    }
    if($Node2 = $toastXml.SelectSingleNode('//text[@id = ''2'']'))
    {
        $Node2.AppendChild($toastXml.CreateTextNode($MessageLine1)) > $null
    }
    if($Node3 = $toastXml.SelectSingleNode('//text[@id = ''3'']'))
    {
        $Node3.AppendChild($toastXml.CreateTextNode($MessageLine2)) > $null
    }
    if($NodeImg = $toastXml.SelectSingleNode('//image[@id = ''1'']'))
    {
        $NodeImg.SetAttribute('src', $Thumbnail) > $null
    }

    #Convert back to WinRT type
    $xml = New-Object Windows.Data.Xml.Dom.XmlDocument
    $xml.LoadXml($toastXml.OuterXml)

    $toast = [Windows.UI.Notifications.ToastNotification]::new($xml)
    $toast.Tag = "PowerShell"
    $toast.Group = "PowerShell"
    $toast.ExpirationTime = [DateTimeOffset]::Now.AddMinutes(5)

    $notifier = [Windows.UI.Notifications.ToastNotificationManager]::CreateToastNotifier("PowerShell")
    $notifier.Show($toast);
}