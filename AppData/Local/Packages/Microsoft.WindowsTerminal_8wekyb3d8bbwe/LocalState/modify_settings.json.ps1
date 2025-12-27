# Windows Terminal settings modify script for chezmoi
# Merges essentials while preserving local profiles

$ErrorActionPreference = "SilentlyContinue"

# Chezmoi source directory
$chezmoiSource = if ($env:CHEZMOI_SOURCE_DIR) { $env:CHEZMOI_SOURCE_DIR } else { "$env:USERPROFILE\.local\share\chezmoi" }
$essentialsPath = "$chezmoiSource\AppData\Local\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\essentials.json"

# Fallback to destination directory
if (-not (Test-Path $essentialsPath)) {
    $essentialsPath = "$env:USERPROFILE\AppData\Local\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\essentials.json"
}

# Read stdin (piped from interpreter wrapper) - collect all input into string
$stdinContent = @($input) -join ""

# Backup target file before modification
$targetPath = "$env:USERPROFILE\AppData\Local\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"
if (Test-Path $targetPath) {
    Copy-Item $targetPath "$targetPath.backup" -Force
}

# Pass through if essentials.json doesn't exist
if (-not (Test-Path $essentialsPath)) {
    Write-Output $stdinContent
    exit 0
}

# Handle empty input (fresh install)
if ([string]::IsNullOrWhiteSpace($stdinContent)) {
    $stdinContent = '{"profiles":{"defaults":{},"list":[]},"schemes":[],"actions":[],"keybindings":[]}'
}

$ErrorActionPreference = "Stop"

# Load JSON files
$current = $stdinContent | ConvertFrom-Json
$essentials = Get-Content $essentialsPath -Raw | ConvertFrom-Json

# Merge global settings
foreach ($prop in $essentials.globalSettings.PSObject.Properties) {
    $current | Add-Member -NotePropertyName $prop.Name -NotePropertyValue $prop.Value -Force
}

# Set profile defaults
$current.profiles.defaults = $essentials.profileDefaults

# Replace actions and keybindings entirely
$current.actions = $essentials.actions
$current.keybindings = $essentials.keybindings

# Merge schemes: keep local schemes not in essentials, add essentials
$essentialSchemeNames = $essentials.schemes | ForEach-Object { $_.name }
$localSchemes = @($current.schemes | Where-Object { $_.name -notin $essentialSchemeNames })
$current.schemes = @($localSchemes) + @($essentials.schemes)

# Reorder profiles
$gitBashGuid = $essentials.gitBashProfile.guid
$powerShellGuid = $essentials.powerShellProfile.guid

# Find existing PowerShell profile and merge
$existingPowerShell = $current.profiles.list | Where-Object { $_.guid -eq $powerShellGuid }
$mergedPowerShell = if ($existingPowerShell) {
    foreach ($prop in $essentials.powerShellProfile.PSObject.Properties) {
        $existingPowerShell | Add-Member -NotePropertyName $prop.Name -NotePropertyValue $prop.Value -Force
    }
    $existingPowerShell
} else {
    $essentials.powerShellProfile
}

# Get other profiles (excluding Git Bash and PowerShell)
$otherProfiles = @($current.profiles.list | Where-Object {
    $_.guid -ne $gitBashGuid -and $_.guid -ne $powerShellGuid
})

# Reorder: Git Bash first, PowerShell second, others third
$current.profiles.list = @($essentials.gitBashProfile) + @($mergedPowerShell) + $otherProfiles

# Set Git Bash as default profile
$current | Add-Member -NotePropertyName "defaultProfile" -NotePropertyValue $gitBashGuid -Force

# Output merged JSON
$current | ConvertTo-Json -Depth 20
