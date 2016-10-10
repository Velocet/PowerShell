# Resize the standard console window
function Resize-ConsoleWindow
{
    ##
    ## Author   : Roman Kuzmin
    ## Synopsis : Resize console window/buffer using arrow keys
    ## Link     : http://stackoverflow.com/questions/153983/are-there-any-better-command-prompts-for-windows/188086#188086
    ## Link     : https://gist.github.com/lpaglia/9965434

    function Set-ConsoleSize($w, $h)
    {
        New-Object System.Management.Automation.Host.Size($w, $h)
    }

    Write-Host '[Arrows] resize  [Esc] exit ...'
    $ErrorActionPreference = 'SilentlyContinue'
    for($ui = $Host.UI.RawUI;;)
    {
        $b = $ui.BufferSize
        $w = $ui.WindowSize
    
        switch($ui.ReadKey(6).VirtualKeyCode)
        {
            37 {
                $w = Set-ConsoleSize ($w.width - 1) $w.height
                $ui.WindowSize = $w
                $ui.BufferSize = Set-ConsoleSize $w.width $b.height
                break
            }
            39 {
                $w = Set-ConsoleSize ($w.width + 1) $w.height
                $ui.BufferSize = Set-ConsoleSize $w.width $b.height
                $ui.WindowSize = $w
                break
            }
            38 {
                $ui.WindowSize = Set-ConsoleSize $w.width ($w.height - 1)
                break
            }
            40 {
                $w = Set-ConsoleSize $w.width ($w.height + 1)
                if ($w.height -gt $b.height) {
                    $ui.BufferSize = Set-ConsoleSize $b.width $w.height
                }
                $ui.WindowSize = $w
                break
            }
            27 {
                return
            }
        }
    }
}

New-Alias -Name rcw -Value Resize-ConsoleWindow