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
- `run_once_` → Scripts that run once per machine (tracked by checksum)

### Key Components

| Source Path | Target | Purpose |
|-------------|--------|---------|
| `dot_bashrc` | `~/.bashrc` | Shell aliases, fzf config, zoxide, oh-my-posh |
| `dot_gitconfig` | `~/.gitconfig` | Git aliases, diff tools, credentials |
| `dot_claude/` | `~/.claude/` | Claude Code settings with modify script |
| `dot_config/chezmoi/` | `~/.config/chezmoi/` | Chezmoi config (merge tool, interpreters) |
| `readonly_Documents/PowerShell/` | PowerShell profile | Read-only PS profile |
| `dotfiles2-apps/` | N/A | Installation scripts and app bundles |

### Run-Once Scripts

Scripts executed once during `chezmoi apply`:
- `run_once_01_install-core.ps1` - Installs Git and UniGetUI via winget
- `run_once_02_install-fonts.ps1` - Installs MesloLGM Nerd Font

### Modify Scripts Pattern

This repo uses **modify scripts** (PowerShell) for merging settings while preserving local state:

**Claude Code** (`dot_claude/modify_settings.json.ps1`): Syncs `permissions` and `statusLine` from `essentials.json`, preserves local `enabledPlugins`

### Installation Stages (Fresh Windows)

1. **Bootstrap**: `winget install twpayne.chezmoi`
2. **Dotfiles + Core**: `chezmoi init --apply https://github.com/NikiforovAll/dotfiles2`
3. **Runtimes**: `winget import -i dotfiles2-apps/runtimes.json`
4. **Apps**: `pwsh -File dotfiles2-apps/install-bundle.ps1`

### External Dependencies

Configured in `.chezmoiexternal.toml`:
- `.claude/nikiforovall` - Private Claude config from `https://github.com/NikiforovAll/private-claude` (refreshed every 24h)

## Development Notes

- **PowerShell scripts** (`.ps1`) are executed via `pwsh` (configured in `dot_config/chezmoi/chezmoi.toml`)
- **Merge conflicts** open in VS Code with 3-way merge
- `README.md` and `CLAUDE.md` are in `.chezmoiignore` (not deployed to home)
