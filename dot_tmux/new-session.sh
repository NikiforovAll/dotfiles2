#!/usr/bin/env bash
# Bound every tmux call: a wedged server makes a bare `tmux` block with no
# deadline, and `bind C` runs this without -b. See agents.sh in the
# tmux@nikiforovall plugin for the full note.
if command -v timeout >/dev/null 2>&1; then
  tmux() { command timeout -k 1 "${CLAUDE_TMUX_EXEC_TIMEOUT:-2}" tmux "$@"; }
fi

name="$1"
path="${2:-$HOME}"
path="${path/#~/$HOME}"  # expand leading ~ since it won't expand inside quotes
TMUX="" tmux new-session -d -s "$name" -c "$path" && tmux switch-client -t "$name"
