#!/usr/bin/env bash
# Runs once after a fresh tmux server start (chained after resurrect restore).
# Ensures the claude-code-hub session exists and npm start is running in it —
# resurrect can't restore processes on Windows (MSYS2 ps lacks -o support).
set -euo pipefail

SESSION="claude-code-hub"
PROJ="$HOME/dev/claude-code-hub"

if ! tmux has-session -t="$SESSION" 2>/dev/null; then
  tmux new-session -ds "$SESSION" -c "$PROJ"
fi

# Skip if the app is already up. Can't trust #{pane_current_command} here:
# MSYS2 tmux can't see Windows-native children, so it reports "bash" even
# while npm is running — probe the app's port instead (kanban, 3541).
if (exec 3<>/dev/tcp/127.0.0.1/3541) 2>/dev/null; then
  exec 3>&- 3<&-
  exit 0
fi

tmux send-keys -t "$SESSION" "npm start" Enter
