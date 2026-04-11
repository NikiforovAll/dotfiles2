#!/usr/bin/env bash
name="$1"
path="${2:-$HOME}"
path="${path/#~/$HOME}"  # expand leading ~ since it won't expand inside quotes
TMUX="" tmux new-session -d -s "$name" -c "$path" && tmux switch-client -t "$name"
