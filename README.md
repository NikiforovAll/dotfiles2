# Windows Dotfiles

## Quick Start (Fresh Windows)

### Stage 1: Bootstrap
```powershell
winget install twpayne.chezmoi --source winget
```

### Stage 2: Dotfiles + Core + Fonts (Automatic)
```powershell
chezmoi init --apply https://github.com/NikiforovAll/dotfiles2
```
This automatically installs:
- Git
- UniGetUI
- MesloLGM Nerd Font

### Stage 3: Runtimes
```powershell
cd ~/.local/share/chezmoi/dotfiles2-apps
winget import -i runtimes.json --accept-package-agreements --accept-source-agreements
```

### Stage 4: Apps
```powershell
pwsh -File install-bundle.ps1        # or: pwsh -File install-bundle.ps1 -WhatIf
```
Alternative: UniGetUI → File → Import Bundle → `uniget.ubundle`

### Stage 5: Manual Installations

The following tools are installed using native installers:
- Bun
- OpenCode
- Claude Code

## Update

### Update Dotfiles
```powershell
chezmoi update
```
