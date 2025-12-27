# Dotfiles Apps Installation

Scripts and bundles for installing applications after `chezmoi apply`.

## Installation Flow

```powershell
# Stage 1: Bootstrap
  winget install twpayne.chezmoi

# Stage 1.5: Dotfiles + Core (automatic)
  chezmoi init --apply https://github.com/NikiforovAll/dotfiles2
        # └── run_once_01: Git, UniGetUI
        # └── run_once_02: MesloLGM Nerd Font

# Change directory
 cd ~\dotfiles2-apps\

# Stage 2: Runtimes
  winget import -i runtimes.json --accept-package-agreements --accept-source-agreements

# Stage 3: Apps (primary method)
  pwsh -File install-bundle.ps1
```

## install-bundle.ps1

Primary installation script. Parses `uniget.ubundle` and installs packages via their native package managers.

**Note:** Installs **latest versions** (version field in bundle is for reference only).

### Usage

```powershell
# Dry run - preview what will be installed
pwsh -File install-bundle.ps1 -WhatIf

# Install all packages
pwsh -File install-bundle.ps1

# Install specific manager only
pwsh -File install-bundle.ps1 -Manager Winget
pwsh -File install-bundle.ps1 -Manager Npm
pwsh -File install-bundle.ps1 -Manager DotNetTool
```

## Files

| File                 | Purpose                                                    |
| -------------------- | ---------------------------------------------------------- |
| `install-bundle.ps1` | Primary installer - parses ubundle, calls package managers |
| `uniget.ubundle`     | Package list (UniGetUI export format)                      |
| `runtimes.json`      | Winget import file for dev runtimes                        |

## Updating Package List

1. Export from UniGetUI: File → Export → select packages → Save as `.ubundle`
2. Or manually edit `uniget.ubundle`

## Alternative: UniGetUI Import

You can also import `uniget.ubundle` directly in UniGetUI:

- File → Import Bundle → select `uniget.ubundle`

This gives you a GUI to review and select packages before installing.
