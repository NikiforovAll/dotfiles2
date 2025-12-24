# Windows Terminal Settings (chezmoi modify_ script)

This folder uses a **modify_ script** approach instead of a static `settings.json`. This allows syncing essential settings while preserving local auto-discovered profiles.

## How It Works

1. `chezmoi apply` runs `modify_settings.json` script
2. Script reads current `settings.json` from your machine (via stdin)
3. Merges essentials from `essentials.json` using `jq`
4. Outputs merged result (chezmoi writes it back)

## What Gets Synced

| Category | Items |
|----------|-------|
| Global settings | `launchMode`, `focusFollowMouse`, `copyOnSelect`, `disableAnimations`, etc. |
| Profile defaults | `colorScheme: ayu`, `snapOnInput`, font settings |
| Actions | 8 custom actions (toggleFocusMode, find, splitPane, etc.) |
| Keybindings | 8 custom keybindings |
| Color schemes | `ayu`, `vscode-windows-terminal-theme` |
| Profiles | Git Bash (1st), PowerShell Core with Ottosson theme (2nd) |

## Dependencies

- **jq** - JSON processor (script gracefully skips if not installed)

## Manual Usage

To apply the script manually (outside of chezmoi):

```bash
# Preview merged result
cat ~/AppData/Local/Packages/Microsoft.WindowsTerminal_8wekyb3d8bbwe/LocalState/settings.json \
  | bash modify_settings.json

# Apply changes
cat ~/AppData/Local/Packages/Microsoft.WindowsTerminal_8wekyb3d8bbwe/LocalState/settings.json \
  | bash modify_settings.json \
  > ~/AppData/Local/Packages/Microsoft.WindowsTerminal_8wekyb3d8bbwe/LocalState/settings.json.new \
  && mv ~/AppData/Local/Packages/Microsoft.WindowsTerminal_8wekyb3d8bbwe/LocalState/settings.json.new \
       ~/AppData/Local/Packages/Microsoft.WindowsTerminal_8wekyb3d8bbwe/LocalState/settings.json
```

## Adding New Settings

1. Edit `essentials.json`
2. Add to appropriate section:
   - `globalSettings` - top-level WT settings
   - `profileDefaults` - default profile settings
   - `actions` / `keybindings` - shortcuts
   - `schemes` - color schemes
   - `gitBashProfile` / `powerShellProfile` - profile customizations
3. Run `chezmoi apply` or apply manually

## Profile Order

The script enforces this order:
1. **Git Bash** (default profile)
2. **PowerShell Core** (with Ottosson theme)
3. All other profiles (preserved in original order)
