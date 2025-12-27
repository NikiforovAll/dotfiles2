# Windows Terminal Settings (chezmoi modify\_ script)

This folder uses a **modify\_ script** approach instead of a static `settings.json`. This allows syncing essential settings while preserving local auto-discovered profiles.

## How It Works

1. `chezmoi apply` runs `modify_settings.json.ps1` script
2. Script reads current `settings.json` from your machine (via stdin)
3. Merges essentials from `essentials.json` using PowerShell's native JSON handling
4. Outputs merged result (chezmoi writes it back)

## What Gets Synced

| Category         | Items                                                                       |
| ---------------- | --------------------------------------------------------------------------- |
| Global settings  | `launchMode`, `focusFollowMouse`, `copyOnSelect`, `disableAnimations`, etc. |
| Profile defaults | `colorScheme: ayu`, `snapOnInput`, font settings                            |
| Actions          | 8 custom actions (toggleFocusMode, find, splitPane, etc.)                   |
| Keybindings      | 8 custom keybindings                                                        |
| Color schemes    | `ayu`, `vscode-windows-terminal-theme`                                      |
| Profiles         | Git Bash (1st), PowerShell Core with Ottosson theme (2nd)                   |

## What Gets Preserved

- Local auto-discovered profiles (WSL, Azure Cloud Shell, etc.)
- Custom color schemes not in essentials
- Any other local settings not overwritten by essentials

## Dependencies

- **PowerShell 7+** (pwsh) - No external tools required

## Manual Usage

To test the script manually (outside of chezmoi):

```powershell
# Preview merged result
Get-Content ~/AppData/Local/Packages/Microsoft.WindowsTerminal_8wekyb3d8bbwe/LocalState/settings.json -Raw |
  pwsh -NoProfile -File modify_settings.json.ps1

# Via chezmoi
chezmoi diff ~/AppData/Local/Packages/Microsoft.WindowsTerminal_8wekyb3d8bbwe/LocalState/settings.json
chezmoi apply ~/AppData/Local/Packages/Microsoft.WindowsTerminal_8wekyb3d8bbwe/LocalState/settings.json
```

## Adding New Settings

1. Edit `essentials.json`
2. Add to appropriate section:
   - `globalSettings` - top-level WT settings
   - `profileDefaults` - default profile settings
   - `actions` / `keybindings` - shortcuts
   - `schemes` - color schemes
   - `gitBashProfile` / `powerShellProfile` - profile customizations
3. Run `chezmoi apply`

## Profile Order

The script enforces this order:

1. **Git Bash** (set as default profile)
2. **PowerShell Core** (with Ottosson theme merged)
3. All other profiles (preserved in original order)
