param(
    [Parameter(Mandatory = $true)]
    [string]$Email
)

$ErrorActionPreference = "Stop"

$SshDir = Join-Path $HOME ".ssh"
$KeyPath = Join-Path $SshDir "github"
$ConfigPath = Join-Path $SshDir "config"

Write-Host "==> Creating SSH directory..."
New-Item -ItemType Directory -Force -Path $SshDir | Out-Null

Write-Host "==> Generating GitHub SSH key..."
ssh-keygen -t ed25519 -C $Email -f $KeyPath

Write-Host "==> Creating SSH config..."

@"
Host github.com
  HostName github.com
  User git
  IdentityFile ~/.ssh/github
  IdentitiesOnly yes
"@ | Set-Content -Path $ConfigPath -Encoding ascii

Write-Host "==> Securing private key permissions..."
icacls $KeyPath /inheritance:r | Out-Null
icacls $KeyPath /grant:r "$env:USERNAME:F" | Out-Null
icacls $KeyPath /remove "Users" "Authenticated Users" "Everyone" 2>$null | Out-Null

Write-Host ""
Write-Host "SSH key generated."
Write-Host "Your public key has been copied to clipboard."

Get-Content "$KeyPath.pub" | Set-Clipboard

Write-Host ""
Write-Host "Paste it into:"
Write-Host "GitHub > Settings > SSH and GPG keys > New SSH key"
Write-Host ""
Write-Host "Then test with:"
Write-Host "ssh -i $($KeyPath.Replace('\','/')) -o IdentitiesOnly=yes -T git@github.com"