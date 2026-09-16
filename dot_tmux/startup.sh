#!/usr/bin/env bash
# Runs once after a fresh tmux server start (chained after resurrect restore).
# Ensures the claude-code-hub session exists and npm start is running in it —
# resurrect can't restore processes on Windows (MSYS2 ps lacks -o support).
set -euo pipefail

# Bound every tmux call: a wedged server makes a bare `tmux` block with no
# deadline, and this runs from the server's own startup chain. See agents.sh in
# the tmux@nikiforovall plugin for the full note.
if command -v timeout >/dev/null 2>&1; then
  tmux() { command timeout -k 1 "${CLAUDE_TMUX_EXEC_TIMEOUT:-2}" tmux "$@"; }
fi

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
