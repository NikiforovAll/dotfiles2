#!/usr/bin/env bash
set -euo pipefail

# tmux hands a display-popup command TERM=dumb, and fzf 0.73 paints through
# terminfo, so a dumb terminal draws an empty popup. Full note in sesh.sh.
if [[ "${TERM:-dumb}" == dumb ]]; then
  export TERM=screen-256color
fi

if command -v timeout >/dev/null 2>&1; then
  tmux() { command timeout -k 1 "${CLAUDE_TMUX_EXEC_TIMEOUT:-2}" tmux "$@"; }
fi

DOWNLOADS_DIR="${TMUX_DOWNLOADS_DIR:-$HOME/Downloads}"
SELF="${BASH_SOURCE[0]}"

# The path goes to PowerShell through an env var, so names with quotes or spaces
# need no escaping.
case "${1:-}" in
  open|reveal)
    action=$1; shift
    for name in "$@"; do
      export P; P=$(cygpath -w "$DOWNLOADS_DIR/$name")
      if [[ $action == open ]]; then
        powershell.exe -NoProfile -Command 'Invoke-Item -LiteralPath $env:P'
      else
        powershell.exe -NoProfile -Command "Start-Process explorer.exe -ArgumentList ('/select,\"' + \$env:P + '\"')"
      fi
    done
    exit 0
    ;;
  help)
    cat <<'EOF'
  Tab         mark item
  Enter       open with default app
  Ctrl-y      copy path(s) to clipboard
  Ctrl-o      show in Explorer
  Ctrl-a      all items
  Ctrl-r      15 most recent
  ?           close this help
EOF
    exit 0
    ;;
  help-toggle)
    if [[ "${FZF_PREVIEW_LABEL:-}" == help ]]; then
      echo 'change-preview-label()+change-preview-window(down,1)+refresh-preview'
    else
      echo 'change-preview-label(help)+change-preview-window(down,7)+refresh-preview'
    fi
    exit 0
    ;;
esac

cd "$DOWNLOADS_DIR"
RECENT_CMD='ls -1t | head -n 15'
ALL_CMD='ls -1t'
mapfile -t picked < <(
  eval "$RECENT_CMD" | fzf --multi --reverse --no-sort \
    --prompt 'recent> ' \
    --bind "?:transform(bash '$SELF' help-toggle)" \
    --bind "ctrl-a:change-prompt(all>    )+reload($ALL_CMD)" \
    --bind "ctrl-r:change-prompt(recent> )+reload($RECENT_CMD)" \
    --bind "enter:execute-silent(bash '$SELF' open {+})+abort" \
    --bind "ctrl-y:accept" \
    --bind "ctrl-o:execute-silent(bash '$SELF' reveal {+})+abort" \
    --preview "[[ \$FZF_PREVIEW_LABEL == help ]] && bash '$SELF' help || ls -ld -- {}" --preview-window down,1
) || exit 0

(( ${#picked[@]} )) || exit 0

paths=()
for name in "${picked[@]}"; do
  p=$(cygpath -w "$DOWNLOADS_DIR/$name")
  [[ "$p" == *' '* ]] && p="\"$p\""
  paths+=("$p")
done
text="${paths[*]}"

# clip.exe reads the console code page, so UTF-8 names turn to mojibake; it reads UTF-16LE as-is.
printf '%s' "$text" | iconv -f UTF-8 -t UTF-16LE | clip.exe
tmux set-buffer -- "$text"
tmux display-message "copied ${#picked[@]} path(s): $text"
