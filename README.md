# Dotfiles [![](https://img.shields.io/badge/Quality-A%2B-brightgreen.svg)](https://img.shields.io/badge/Quality-A%2B-brightgreen.svg)

[![Test dotfiles on macOS](https://github.com/INGCRENGIFO/dotfiles/actions/workflows/test_dotfiles.yml/badge.svg)](https://github.com/INGCRENGIFO/dotfiles/actions/workflows/test_dotfiles.yml)

Personal dotfiles for macOS and Windows workstations.

## Repository Structure

```text
.dotfiles/
├── common/
│   ├── git/
│   ├── vim/
│   └── tool-versions/
├── macos/
│   ├── install.sh
│   ├── ssh.sh
│   ├── zsh/
│   └── install/
└── windows/
    ├── install.ps1
    ├── ssh.ps1
    ├── oh-my-posh/
    ├── winget/
    └── powershell/
```

## Windows

Run the installer from PowerShell 7:

```powershell
.\windows\install.ps1
```

To install the recommended Nerd Font for Oh My Posh:

```powershell
.\windows\install.ps1 -InstallFont
```

After installing the font, configure Windows Terminal and VS Code to use `MesloLGM Nerd Font`.
