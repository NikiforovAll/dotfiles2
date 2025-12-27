# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is a **chezmoi** dotfiles repository for Windows, managing shell configurations, application settings, and development tools. The repository lives at `~/.local/share/chezmoi` (chezmoi's source directory).

## Common Commands

```bash
# Apply dotfiles to the system
chezmoi apply

# Check what would change (dry run)
chezmoi diff

# Update external dependencies (e.g., private-claude repo)
chezmoi apply --refresh-externals

# Check current status
chezmoi status

# Edit a managed file (opens in chezmoi source dir)
chezmoi edit <file>
```

## Architecture

### Chezmoi File Naming Conventions

Files in this repository use chezmoi naming prefixes:
- `dot_` → `.` (e.g., `dot_bashrc` → `~/.bashrc`)
- `modify_` → Script that transforms existing file (receives current content via stdin)
- `readonly_` → Files deployed as read-only

### Key Components

| Source Path | Target | Purpose |
|-------------|--------|---------|
| `dot_bashrc` | `~/.bashrc` | Shell aliases, fzf config, zoxide, oh-my-posh |
| `dot_gitconfig` | `~/.gitconfig` | Git aliases, diff tools, credentials |
| `dot_claude/` | `~/.claude/` | Claude Code settings with modify script |
| `dot_config/chezmoi/` | `~/.config/chezmoi/` | Chezmoi config (merge tool, interpreters) |
| `AppData/Local/Packages/Microsoft.WindowsTerminal_*/` | Windows Terminal | Settings with modify script |
| `dotfiles2-apps/` | N/A | Installation scripts and app bundles |

### Modify Scripts Pattern

This repo uses **modify scripts** for merging settings while preserving local state:

1. **Claude Code** (`dot_claude/modify_settings.json.sh`): Syncs permissions and statusLine from `essentials.json`, preserves local `enabledPlugins`

2. **Windows Terminal** (`AppData/.../modify_settings.json.sh`): Syncs global settings, color schemes, keybindings, profile order while preserving auto-discovered profiles

Both scripts require `jq` and gracefully skip if unavailable.

### External Dependencies

Configured in `.chezmoiexternal.toml`:
- `.claude/nikiforovall` - Private Claude config from `https://github.com/NikiforovAll/private-claude` (refreshed every 24h)

## Development Notes

- **Shell scripts** use bash (chezmoi configured in `dot_config/chezmoi/chezmoi.toml` with `[interpreters.sh] command = "bash"`)
- **Merge conflicts** open in VS Code with 3-way merge
- The `README.md` is in `.chezmoiignore` (not deployed to home)
