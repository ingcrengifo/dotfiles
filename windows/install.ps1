#Requires -Version 7.0

$ErrorActionPreference = "Stop"

$PackagesFile = Join-Path $PSScriptRoot "winget\packages.json"

Write-Host "==> Actualizando fuentes de winget..."
winget source update

Write-Host "==> Instalando paquetes desde packages.json..."
winget import -i $PackagesFile --accept-package-agreements --accept-source-agreements

Write-Host "==> Actualizando paquetes instalados..."
winget upgrade --all --accept-package-agreements --accept-source-agreements

Write-Host "==> Finalizado."