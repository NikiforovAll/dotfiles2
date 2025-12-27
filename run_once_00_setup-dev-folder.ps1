# Setup ~/dev folder and $dev environment variable
# This script runs once during `chezmoi apply`

$ErrorActionPreference = "Continue"

$devPath = Join-Path $env:USERPROFILE "dev"

Write-Host "Setting up dev folder..." -ForegroundColor Cyan

# Create ~/dev folder if it doesn't exist
if (-not (Test-Path $devPath)) {
    New-Item -ItemType Directory -Path $devPath -Force | Out-Null
    Write-Host "  Created $devPath" -ForegroundColor Green
} else {
    Write-Host "  $devPath already exists" -ForegroundColor DarkGray
}

# Set $dev user environment variable
$currentValue = [System.Environment]::GetEnvironmentVariable("dev", "User")
if ($currentValue -ne $devPath) {
    [System.Environment]::SetEnvironmentVariable("dev", $devPath, "User")
    Write-Host "  Set 'dev' environment variable to $devPath" -ForegroundColor Green
} else {
    Write-Host "  'dev' environment variable already set" -ForegroundColor DarkGray
}

Write-Host "Dev folder setup complete!" -ForegroundColor Cyan
