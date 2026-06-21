# PowerShell profile managed by ~/.dotfiles

function Set-OptionalPSReadLineOption {
    param(
        [Parameter(Mandatory = $true)]
        [hashtable]$Options
    )

    if (Get-Command Set-PSReadLineOption -ErrorAction SilentlyContinue) {
        try {
            Set-PSReadLineOption @Options
        } catch {
            # Some hosts load profiles without a full interactive console.
        }
    }
}

Set-OptionalPSReadLineOption @{ EditMode = "Windows" }
Set-OptionalPSReadLineOption @{ PredictionSource = "History" }
Set-OptionalPSReadLineOption @{ PredictionViewStyle = "ListView" }

Set-Alias ll Get-ChildItem
Set-Alias g git
Set-Alias k kubectl
Set-Alias tf terraform

function which($command) {
    Get-Command $command -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Source
}

function dotfiles {
    Set-Location "$HOME\.dotfiles"
}

function reload-profile {
    . $PROFILE
}

$env:EDITOR = "code"

$OhMyPoshTheme = Join-Path $HOME ".dotfiles\windows\oh-my-posh\cristian.omp.json"

if ((Get-Command oh-my-posh -ErrorAction SilentlyContinue) -and (Test-Path $OhMyPoshTheme)) {
    oh-my-posh init pwsh --config $OhMyPoshTheme | Invoke-Expression
}

if (Get-Command mise -ErrorAction SilentlyContinue) {
    mise activate pwsh | Out-String | Invoke-Expression
}
