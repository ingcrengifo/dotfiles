#Requires -Version 7.0

param(
    [switch]$InstallFont,
    [string]$NerdFont = "Meslo"
)

$ErrorActionPreference = "Stop"

$DotfilesDir = Resolve-Path (Join-Path $PSScriptRoot "..")
$PackagesFile = Join-Path $PSScriptRoot "winget\packages.json"
$PowerShellProfileSource = Join-Path $PSScriptRoot "powershell\Microsoft.PowerShell_profile.ps1"

Write-Host "==> Setting up Windows workstation..."

Write-Host "==> Updating winget sources..."
winget source update

if (Test-Path $PackagesFile) {
    Write-Host "==> Installing packages from winget..."
    winget import -i $PackagesFile --accept-package-agreements --accept-source-agreements
} else {
    Write-Host "Winget packages file not found: $PackagesFile"
}

Write-Host "==> Upgrading installed packages..."
winget upgrade --all --accept-package-agreements --accept-source-agreements

if ($InstallFont) {
    Write-Host "==> Installing Nerd Font for Oh My Posh..."

    if (Get-Command oh-my-posh -ErrorAction SilentlyContinue) {
        oh-my-posh font install $NerdFont
    } else {
        Write-Host "Oh My Posh was not found on PATH. Restart your terminal and run:"
        Write-Host "oh-my-posh font install $NerdFont"
    }
}

Write-Host "==> Creating PowerShell profile..."

$ProfileDir = Split-Path $PROFILE.CurrentUserCurrentHost -Parent
New-Item -ItemType Directory -Force -Path $ProfileDir | Out-Null

if (Test-Path $PowerShellProfileSource) {
    Copy-Item $PowerShellProfileSource $PROFILE.CurrentUserCurrentHost -Force
}

Write-Host "==> Configuring Git SSH command for this repo..."

$KeyPath = Join-Path $HOME ".ssh\github"

if (Test-Path $KeyPath) {
    $GitSshKeyPath = $KeyPath.Replace("\", "/")
    git config core.sshCommand "ssh -i $GitSshKeyPath -o IdentitiesOnly=yes"
}

Write-Host ""
Write-Host "✅ Windows setup completed."
Write-Host "Restart your terminal before validating all commands."
Write-Host "If you installed a Nerd Font, set Windows Terminal and VS Code to use MesloLGM Nerd Font."
