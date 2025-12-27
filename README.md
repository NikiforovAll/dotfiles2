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
Installs: .NET SDK, Node.js, Python, PowerShell, Bun

### Stage 4: Apps
Open **UniGetUI** → File → Import Bundle → select `uniget.ubundle`

## Update

### Update Dotfiles
```powershell
chezmoi update
```
