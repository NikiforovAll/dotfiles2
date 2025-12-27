# Install core tools via winget (Git, UniGetUI)
# This script runs once during `chezmoi apply`

$ErrorActionPreference = "Continue"

# Winget return codes: https://github.com/microsoft/winget-cli/blob/master/doc/windows/package-manager/winget/returnCodes.md
$ALREADY_INSTALLED = -1978335189  # 0x8A15002B

$packages = @(
    "Git.Git",
    "MartiCliment.UniGetUI"
)

Write-Host "Installing core tools..." -ForegroundColor Cyan

foreach ($package in $packages) {
    Write-Host "  Installing $package..." -ForegroundColor Yellow
    winget install --id $package --accept-package-agreements --accept-source-agreements --silent

    switch ($LASTEXITCODE) {
        0 { Write-Host "  $package installed successfully" -ForegroundColor Green }
        $ALREADY_INSTALLED { Write-Host "  $package already installed" -ForegroundColor DarkGray }
        default { Write-Host "  $package failed (exit code: $LASTEXITCODE)" -ForegroundColor Red }
    }
}

Write-Host "Core tools installation complete!" -ForegroundColor Cyan
