# Install packages from UniGetUI .ubundle file
# Usage: pwsh -File install-bundle.ps1 [-BundlePath <path>] [-WhatIf] [-Manager <name>]

param(
    [string]$BundlePath = "$PSScriptRoot\uniget.ubundle",
    [switch]$WhatIf,
    [ValidateSet("All", "Winget", "Npm", "DotNetTool")]
    [string]$Manager = "All"
)

$ErrorActionPreference = "Continue"

# Winget return codes
$ALREADY_INSTALLED = -1978335189  # 0x8A15002B

if (-not (Test-Path $BundlePath)) {
    Write-Host "Bundle file not found: $BundlePath" -ForegroundColor Red
    exit 1
}

Write-Host "Parsing bundle: $BundlePath" -ForegroundColor Cyan
$bundle = Get-Content $BundlePath -Raw | ConvertFrom-Json
$packages = $bundle.packages

# Group by manager
$grouped = $packages | Group-Object -Property ManagerName

Write-Host "Found $($packages.Count) packages across $($grouped.Count) managers:" -ForegroundColor Cyan
$grouped | ForEach-Object { Write-Host "  $($_.Name): $($_.Count) packages" -ForegroundColor DarkGray }
Write-Host ""

foreach ($group in $grouped) {
    $managerName = $group.Name

    # Map CLI param to bundle manager name
    $managerFilter = switch ($Manager) {
        "DotNetTool" { ".NET Tool" }
        default { $Manager }
    }

    if ($Manager -ne "All" -and $managerFilter -ne $managerName) {
        continue
    }

    Write-Host "=== $managerName ===" -ForegroundColor Yellow

    foreach ($pkg in $group.Group) {
        $id = $pkg.Id
        $name = $pkg.Name
        $source = $pkg.Source

        if ($WhatIf) {
            Write-Host "  [WhatIf] Would install: $name ($id)" -ForegroundColor DarkGray
            continue
        }

        Write-Host "  Installing: $name" -ForegroundColor White -NoNewline

        switch ($managerName) {
            "Winget" {
                $result = winget install --id $id --source $source --accept-package-agreements --accept-source-agreements --silent 2>&1
                switch ($LASTEXITCODE) {
                    0 { Write-Host " [installed]" -ForegroundColor Green }
                    $ALREADY_INSTALLED { Write-Host " [already installed]" -ForegroundColor DarkGray }
                    default { Write-Host " [failed: $LASTEXITCODE]" -ForegroundColor Red }
                }
            }
            "Npm" {
                npm install -g $id 2>&1 | Out-Null
                if ($LASTEXITCODE -eq 0) {
                    Write-Host " [installed]" -ForegroundColor Green
                } else {
                    Write-Host " [failed]" -ForegroundColor Red
                }
            }
            ".NET Tool" {
                dotnet tool install -g $id 2>&1 | Out-Null
                if ($LASTEXITCODE -eq 0) {
                    Write-Host " [installed]" -ForegroundColor Green
                } elseif ($LASTEXITCODE -eq 1) {
                    # Tool already installed
                    Write-Host " [already installed]" -ForegroundColor DarkGray
                } else {
                    Write-Host " [failed]" -ForegroundColor Red
                }
            }
            default {
                Write-Host " [unsupported manager: $managerName]" -ForegroundColor DarkYellow
            }
        }
    }
    Write-Host ""
}

Write-Host "Done!" -ForegroundColor Cyan
