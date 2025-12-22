# Windows Dotfiles

```bash
winget install twpayne.chezmoi --source winget
```

```bash
chezmoi -- init --apply https://github.com/NikiforovAll/dotfiles2
```

## Update External Dependencies

```bash
chezmoi apply --refresh-externals
```