#Requires -Version 7.0

param(
    [switch]$InstallFont,
    [string]$NerdFont = "Meslo"
)

$ErrorActionPreference = "Stop"

$DotfilesDir = Resolve-Path (Join-Path $PSScriptRoot "..")
$PackagesFile = Join-Path $PSScriptRoot "winget\packages.json"
$PowerShellProfileSource = Join-Path $PSScriptRoot "powershell\Microsoft.PowerShell_profile.ps1"
$WindowsGitConfigSource = Join-Path $PSScriptRoot "git\.gitconfig"
$VSCodeSettingsSource = Join-Path $PSScriptRoot "vscode\settings.json"

function Copy-Dotfile {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Source,

        [Parameter(Mandatory = $true)]
        [string]$Destination
    )

    if (-not (Test-Path $Source)) {
        Write-Host "Skipping missing source: $Source"
        return
    }

    $DestinationDir = Split-Path $Destination -Parent

    if ($DestinationDir) {
        New-Item -ItemType Directory -Force -Path $DestinationDir | Out-Null
    }

    if (Test-Path $Destination) {
        $BackupPath = "$Destination.backup"
        Copy-Item $Destination $BackupPath -Force
    }

    Copy-Item $Source $Destination -Force
}

function Copy-DotfileDirectory {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Source,

        [Parameter(Mandatory = $true)]
        [string]$Destination
    )

    if (-not (Test-Path $Source)) {
        Write-Host "Skipping missing source: $Source"
        return
    }

    if (Test-Path $Destination) {
        $BackupPath = "$Destination.backup"

        if (Test-Path $BackupPath) {
            Remove-Item $BackupPath -Recurse -Force
        }

        Copy-Item $Destination $BackupPath -Recurse -Force
        Remove-Item $Destination -Recurse -Force
    }

    New-Item -ItemType Directory -Force -Path (Split-Path $Destination -Parent) | Out-Null
    Copy-Item $Source $Destination -Recurse -Force
}

function Merge-JsonFile {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Source,

        [Parameter(Mandatory = $true)]
        [string]$Destination
    )

    if (-not (Test-Path $Source)) {
        return
    }

    $DestinationDir = Split-Path $Destination -Parent
    New-Item -ItemType Directory -Force -Path $DestinationDir | Out-Null

    try {
        $SourceJson = Get-Content $Source -Raw | ConvertFrom-Json
    } catch {
        Write-Host "Skipping invalid JSON source: $Source"
        return
    }

    if (Test-Path $Destination) {
        Copy-Item $Destination "$Destination.backup" -Force
        try {
            $DestinationJson = Get-Content $Destination -Raw | ConvertFrom-Json
        } catch {
            Write-Host "Skipping JSON merge with unsupported destination format: $Destination"
            return
        }
    } else {
        $DestinationJson = [pscustomobject][ordered]@{}
    }

    foreach ($Property in $SourceJson.PSObject.Properties) {
        $DestinationJson | Add-Member -MemberType NoteProperty -Name $Property.Name -Value $Property.Value -Force
    }

    $DestinationJson | ConvertTo-Json -Depth 20 | Set-Content -Path $Destination -Encoding utf8
}

function Update-WindowsTerminalSettings {
    param(
        [Parameter(Mandatory = $true)]
        [string]$FontFace
    )

    $SettingsPaths = @(
        (Join-Path $env:LOCALAPPDATA "Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"),
        (Join-Path $env:LOCALAPPDATA "Packages\Microsoft.WindowsTerminalPreview_8wekyb3d8bbwe\LocalState\settings.json")
    )

    foreach ($SettingsPath in $SettingsPaths) {
        if (-not (Test-Path $SettingsPath)) {
            continue
        }

        try {
            $Settings = Get-Content $SettingsPath -Raw | ConvertFrom-Json
        } catch {
            Write-Host "Skipping Windows Terminal settings with unsupported JSON format: $SettingsPath"
            continue
        }

        $Profiles = @($Settings.profiles.list)

        if (-not $Profiles) {
            continue
        }

        $PowerShellProfile = $Profiles |
            Where-Object {
                $_.commandline -match "pwsh" -or
                $_.source -eq "Windows.Terminal.PowershellCore" -or
                $_.name -eq "PowerShell"
            } |
            Select-Object -First 1

        if (-not $PowerShellProfile) {
            continue
        }

        if ($PowerShellProfile.guid) {
            $Settings | Add-Member -MemberType NoteProperty -Name "defaultProfile" -Value $PowerShellProfile.guid -Force
        }

        if (-not $PowerShellProfile.font) {
            $PowerShellProfile | Add-Member -MemberType NoteProperty -Name "font" -Value ([ordered]@{}) -Force
        }

        $PowerShellProfile.font | Add-Member -MemberType NoteProperty -Name "face" -Value $FontFace -Force

        Copy-Item $SettingsPath "$SettingsPath.backup" -Force
        $Settings | ConvertTo-Json -Depth 100 | Set-Content -Path $SettingsPath -Encoding utf8
        Write-Host "Updated Windows Terminal settings: $SettingsPath"
    }
}

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

Copy-Dotfile $PowerShellProfileSource $PROFILE.CurrentUserCurrentHost

Write-Host "==> Installing common dotfiles..."

Copy-Dotfile $WindowsGitConfigSource (Join-Path $HOME ".gitconfig")
Copy-Dotfile (Join-Path $DotfilesDir "common\git\.gitignore") (Join-Path $HOME ".gitignore")
Copy-Dotfile (Join-Path $DotfilesDir "common\vim\.vimrc") (Join-Path $HOME ".vimrc")
Copy-Dotfile (Join-Path $DotfilesDir "common\tool-versions\.tool-versions") (Join-Path $HOME ".tool-versions")
Copy-DotfileDirectory (Join-Path $DotfilesDir ".config\nvim") (Join-Path $env:LOCALAPPDATA "nvim")

Write-Host "==> Configuring Git SSH command for this repo..."

$KeyPath = Join-Path $HOME ".ssh\github"

if (Test-Path $KeyPath) {
    $GitSshKeyPath = $KeyPath.Replace("\", "/")
    git config core.sshCommand "ssh -i $GitSshKeyPath -o IdentitiesOnly=yes"
}

Write-Host "==> Configuring application settings..."

Merge-JsonFile $VSCodeSettingsSource (Join-Path $env:APPDATA "Code\User\settings.json")
Update-WindowsTerminalSettings -FontFace "MesloLGM Nerd Font"

Write-Host ""
Write-Host "✅ Windows setup completed."
Write-Host "Restart your terminal before validating all commands."
