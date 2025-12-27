# Claude Code settings modify script for chezmoi
# Syncs permissions and statusLine, preserves everything else

$ErrorActionPreference = "SilentlyContinue"

# Chezmoi source directory
$chezmoiSource = if ($env:CHEZMOI_SOURCE_DIR) { $env:CHEZMOI_SOURCE_DIR } else { "$env:USERPROFILE\.local\share\chezmoi" }
$essentialsPath = "$chezmoiSource\dot_claude\essentials.json"

# Fallback to destination directory
if (-not (Test-Path $essentialsPath)) {
    $essentialsPath = "$env:USERPROFILE\.claude\essentials.json"
}

# Read stdin (piped from interpreter wrapper) - collect all input into string
$stdinContent = @($input) -join ""

# Pass through if essentials.json doesn't exist
if (-not (Test-Path $essentialsPath)) {
    Write-Output $stdinContent
    exit 0
}

# Handle empty input (fresh install)
if ([string]::IsNullOrWhiteSpace($stdinContent)) {
    $stdinContent = '{"permissions":{"allow":[],"deny":[],"ask":[]},"enabledPlugins":{}}'
}

$ErrorActionPreference = "Stop"

# Load JSON files as PSObjects
$current = $stdinContent | ConvertFrom-Json
$essentials = Get-Content $essentialsPath -Raw | ConvertFrom-Json

# Merge: update permissions and statusLine, preserve all other properties
$current.permissions = $essentials.permissions

# Add or update statusLine
if ($current.PSObject.Properties['statusLine']) {
    $current.statusLine = $essentials.statusLine
} else {
    $current | Add-Member -NotePropertyName "statusLine" -NotePropertyValue $essentials.statusLine
}

# Output merged JSON
$current | ConvertTo-Json -Depth 10
