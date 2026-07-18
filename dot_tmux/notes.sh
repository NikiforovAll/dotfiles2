#!/usr/bin/env bash
set -euo pipefail

NOTES_DIR="${TMUX_NOTES_DIR:-$HOME/notes}"

# Session name = project scope (sessions are created per-project by sesh.sh).
current_session() {
  tmux display-message -p ${TMUX_PANE:+-t "$TMUX_PANE"} '#S' 2>/dev/null || echo scratch
}

note_file() {
  local session="${1:-$(current_session)}"
  printf '%s/%s.md' "$NOTES_DIR" "$session"
}

# VS Code is a Windows binary — feed it a Windows-style path.
winpath() {
  command -v cygpath >/dev/null 2>&1 && cygpath -m "$1" || printf '%s' "$1"
}

ensure_file() {
  local file="$1" session="$2"
  mkdir -p "$NOTES_DIR"
  [[ -f "$file" ]] || printf '# %s\n' "$session" > "$file"
}

# Append a timestamped bullet under today's heading, creating the heading on
# the first capture of the day.
capture() {
  local text="${1:-}"
  [[ -z "$text" ]] && exit 0
  local session file today
  session=$(current_session)
  file=$(note_file "$session")
  today=$(date +%Y-%m-%d)
  ensure_file "$file" "$session"
  grep -q "^## $today$" "$file" || printf '\n## %s\n' "$today" >> "$file"
  printf -- '- %s %s\n' "$(date +%H:%M)" "$text" >> "$file"
  tmux display-message "noted → $(basename "$file")"
}

# code's Windows shim has flaky exit codes (e.g. when forwarding to a running
# instance) — launch detached and ignore its status so the binding never errors.
launch_code() { (code "$@" >/dev/null 2>&1 &) || true; }

open() {
  local file
  file=$(note_file)
  ensure_file "$file" "$(current_session)"
  launch_code "$(winpath "$file")"
}

preview() {
  local f="$NOTES_DIR/${1:-}"
  [[ -f "$f" ]] && bat --color=always --style=plain "$f" 2>/dev/null || cat "$f" 2>/dev/null || echo "(no preview)"
}

# fzf over all project notes; Enter opens in VS Code, Ctrl-r greps note contents.
pick() {
  export NOTES_SCRIPT="$0"
  mkdir -p "$NOTES_DIR"
  LIST_CMD="ls -t '$NOTES_DIR' 2>/dev/null | grep '\\.md$'"
  GREP_CMD="rg --no-heading --line-number --color=always -S {q} '$NOTES_DIR' 2>/dev/null | sed 's|^.*[/\\\\]||'"
  choice=$(FZF_DEFAULT_COMMAND="$LIST_CMD" fzf --ansi --reverse --prompt='notes> ' \
    --preview "bash $NOTES_SCRIPT preview {1}" \
    --preview-window='right,60%,border-left' \
    --delimiter=: --with-nth=1 \
    --bind "ctrl-r:change-prompt(grep> )+reload:sleep 0.1; $GREP_CMD" \
    --bind "change:transform:[[ \$FZF_PROMPT == grep* ]] && echo \"reload:sleep 0.1; $GREP_CMD\"" \
    --bind "ctrl-f:change-prompt(notes> )+reload($LIST_CMD)") || exit 0
  [[ -z "$choice" ]] && exit 0
  file="$NOTES_DIR/${choice%%:*}"
  line=$(printf '%s' "$choice" | awk -F: 'NF>1 && $2 ~ /^[0-9]+$/ {print $2}')
  launch_code --goto "$(winpath "$file")${line:+:$line}"
}

case "${1:-pick}" in
  capture) shift; capture "${1:-}" ;;
  open) open ;;
  preview) shift; preview "${1:-}" ;;
  pick) pick ;;
esac
