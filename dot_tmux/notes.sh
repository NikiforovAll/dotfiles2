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
# Redirecting fds is not enough: called from inside a display-popup this left an
# empty overlay on screen, so never call it from a popup (see pick).
launch_code() { (nohup code "$@" </dev/null >/dev/null 2>&1 &) || true; }

# Entry point for the popup: reparents the editor launch onto the tmux server.
open_file() { launch_code --goto "${1:-}"; }

open() {
  local file
  file=$(note_file)
  ensure_file "$file" "$(current_session)"
  launch_code "$(winpath "$file")"
}

preview() {
  local f="$NOTES_DIR/${1:-}"
  # if/else, not && ||: a failing bat must not fall through to an unstyled cat.
  if [[ -f "$f" ]]; then
    bat --color=always --style=plain "$f" 2>/dev/null || cat "$f"
  else
    echo "(no preview)"
  fi
}

# fzf over all project notes, newest first; Enter opens in VS Code.
pick() {
  export NOTES_SCRIPT="$0"
  mkdir -p "$NOTES_DIR"
  LIST_CMD="ls -t '$NOTES_DIR' 2>/dev/null | grep '\\.md$'"
  choice=$(FZF_DEFAULT_COMMAND="$LIST_CMD" fzf --reverse --prompt='notes> ' \
    --preview "bash $NOTES_SCRIPT preview {}" \
    --preview-window='right,60%,border-left') || exit 0
  [[ -z "$choice" ]] && exit 0
  # Launching the editor from inside the popup left the overlay hanging on the
  # screen; routing through the server keeps it off the popup entirely.
  tmux run-shell -b "bash '$NOTES_SCRIPT' open-file '$(winpath "$NOTES_DIR/$choice")'"
}

case "${1:-pick}" in
  capture) shift; capture "${1:-}" ;;
  open) open ;;
  open-file) shift; open_file "${1:-}" ;;
  preview) shift; preview "${1:-}" ;;
  pick) pick ;;
esac
