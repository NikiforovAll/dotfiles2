# Install tmux into ~/bin for Git Bash
# Downloads tmux + libevent MSYS2 packages and places binaries in ~/bin (already in Git Bash PATH)
# This script runs once during `chezmoi apply`

$ErrorActionPreference = "Stop"

$binDir = Join-Path $env:USERPROFILE "bin"
$tmuxPath = Join-Path $binDir "tmux.exe"

if (Test-Path $tmuxPath) {
    Write-Host "  tmux already installed at $tmuxPath" -ForegroundColor DarkGray
    exit 0
}

Write-Host "Installing tmux into ~/bin..." -ForegroundColor Cyan

New-Item -ItemType Directory -Path $binDir -Force | Out-Null

$tempDir = Join-Path $env:TEMP "tmux-install-$(Get-Random)"
New-Item -ItemType Directory -Path $tempDir -Force | Out-Null

$zstdUrl = "https://github.com/facebook/zstd/releases/download/v1.5.7/zstd-v1.5.7-win64.zip"
$packages = @(
    @{ Name = "tmux";     Url = "https://mirror.msys2.org/msys/x86_64/tmux-3.6.a-1-x86_64.pkg.tar.zst" },
    @{ Name = "libevent"; Url = "https://mirror.msys2.org/msys/x86_64/libevent-2.1.12-4-x86_64.pkg.tar.zst" }
)

try {
    $zstdZip = Join-Path $tempDir "zstd.zip"
    Write-Host "  Downloading zstd..." -ForegroundColor Yellow
    Invoke-WebRequest -Uri $zstdUrl -OutFile $zstdZip -UseBasicParsing
    Expand-Archive -Path $zstdZip -DestinationPath $tempDir -Force
    $zstd = Get-ChildItem -Path $tempDir -Recurse -Filter "zstd.exe" | Select-Object -First 1
    if (-not $zstd) { throw "zstd.exe not found after extraction" }

    $extractDir = Join-Path $tempDir "extracted"
    New-Item -ItemType Directory -Path $extractDir -Force | Out-Null

    foreach ($pkg in $packages) {
        $fileName = Split-Path $pkg.Url -Leaf
        $filePath = Join-Path $tempDir $fileName
        $tarName = $fileName -replace '\.zst$', ''
        $tarPath = Join-Path $extractDir $tarName

        Write-Host "  Downloading $($pkg.Name)..." -ForegroundColor Yellow
        Invoke-WebRequest -Uri $pkg.Url -OutFile $filePath -UseBasicParsing

        Write-Host "  Extracting $($pkg.Name)..." -ForegroundColor Yellow
        & $zstd.FullName -d $filePath -o $tarPath --force -q
        Push-Location $extractDir
        tar -xf $tarName
        Pop-Location
    }

    # Copy tmux.exe and libevent DLLs to ~/bin
    $extractedBin = Join-Path $extractDir "usr\bin"
    Get-ChildItem -Path $extractedBin -File | Where-Object {
        $_.Name -match '\.(exe|dll)$'
    } | ForEach-Object {
        Copy-Item -Path $_.FullName -Destination $binDir -Force
        Write-Host "  Installed $($_.Name)" -ForegroundColor DarkGray
    }

    if (Test-Path $tmuxPath) {
        Write-Host "  tmux installed successfully!" -ForegroundColor Green
        & "$tmuxPath" -V
    } else {
        Write-Host "  tmux binary not found after extraction" -ForegroundColor Red
        exit 1
    }
} finally {
    Remove-Item -Recurse -Force $tempDir -ErrorAction SilentlyContinue
}

Write-Host "tmux installation complete!" -ForegroundColor Cyan
Write-Host "  NOTE: tmux only works with MinTTY (git-bash.exe), not cmd/powershell" -ForegroundColor DarkGray
