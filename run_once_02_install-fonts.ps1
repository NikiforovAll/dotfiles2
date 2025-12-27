# Install MesloLGM Nerd Font (user-only, no admin required)
# This script runs once during `chezmoi apply`

$ErrorActionPreference = "Stop"

$fontName = "Meslo"
$fontVersion = "v3.4.0"
$fontUrl = "https://github.com/ryanoasis/nerd-fonts/releases/download/$fontVersion/$fontName.zip"
$tempZip = "$env:TEMP\$fontName.zip"
$extractPath = "$env:TEMP\${fontName}Fonts"
$userFontsFolder = "$env:LOCALAPPDATA\Microsoft\Windows\Fonts"
$fontsRegKey = "HKCU:\Software\Microsoft\Windows NT\CurrentVersion\Fonts"

Write-Host "Installing $fontName Nerd Font..." -ForegroundColor Cyan

# Check if fonts are already installed
$existingFonts = Get-ChildItem -Path $userFontsFolder -Filter "MesloLG*.ttf" -ErrorAction SilentlyContinue
if ($existingFonts.Count -gt 0) {
    Write-Host "  $fontName fonts already installed ($($existingFonts.Count) files found)" -ForegroundColor Green
    exit 0
}

# Download font archive
Write-Host "  Downloading from GitHub releases..." -ForegroundColor Yellow
try {
    Invoke-WebRequest -Uri $fontUrl -OutFile $tempZip -UseBasicParsing
} catch {
    Write-Host "  Failed to download font: $_" -ForegroundColor Red
    exit 1
}

# Extract archive
Write-Host "  Extracting fonts..." -ForegroundColor Yellow
if (Test-Path $extractPath) {
    Remove-Item -Path $extractPath -Recurse -Force
}
Expand-Archive -Path $tempZip -DestinationPath $extractPath -Force

# Create user fonts folder if it doesn't exist
if (-not (Test-Path $userFontsFolder)) {
    New-Item -ItemType Directory -Path $userFontsFolder -Force | Out-Null
}

# Install fonts (only MesloLGM variants for terminal use)
$installedCount = 0
Get-ChildItem -Path $extractPath -Filter "MesloLGM*.ttf" | ForEach-Object {
    $fontPath = Join-Path $userFontsFolder $_.Name
    Copy-Item $_.FullName -Destination $fontPath -Force

    # Register font for current user
    $fontDisplayName = $_.BaseName -replace "NerdFont", " Nerd Font" -replace "Mono", " Mono"
    Set-ItemProperty -Path $fontsRegKey -Name "$fontDisplayName (TrueType)" -Value $fontPath

    $installedCount++
    Write-Host "  Installed: $($_.Name)" -ForegroundColor DarkGray
}

# Cleanup
Remove-Item $tempZip -Force -ErrorAction SilentlyContinue
Remove-Item $extractPath -Recurse -Force -ErrorAction SilentlyContinue

Write-Host "$fontName Nerd Font installed successfully! ($installedCount files)" -ForegroundColor Green
Write-Host "Note: Restart terminal apps to use the new fonts" -ForegroundColor DarkYellow
