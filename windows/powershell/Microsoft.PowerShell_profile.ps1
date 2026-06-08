# PowerShell profile managed by ~/.dotfiles

Set-PSReadLineOption -EditMode Windows
Set-PSReadLineOption -PredictionSource History
Set-PSReadLineOption -PredictionViewStyle ListView

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
