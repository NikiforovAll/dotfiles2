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
cd "$DOWNLOADS_DIR"
mapfile -t picked < <(
  ls -1t | fzf --multi --reverse --no-sort \
    --prompt 'downloads> ' \
    --header 'Tab: mark · Enter: copy path(s) to clipboard' \
    --preview 'ls -ld -- {}' --preview-window down,1
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
