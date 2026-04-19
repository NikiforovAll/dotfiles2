#!/usr/bin/env bash
set -euo pipefail

sanitize() { printf '%s' "$1" | tr ':.' '__'; }

list_tmux() { tmux list-sessions -F '#{session_name}' 2>/dev/null; }

list_zoxide() {
  local home_win home_unix
  home_unix="$HOME"
  home_win=$(command -v cygpath >/dev/null 2>&1 && cygpath -m "$HOME" || echo "$HOME")
  zoxide query -l 2>/dev/null \
    | tr '\\' '/' \
    | sed -e "s|^${home_win}|~|" -e "s|^${home_unix}|~|"
}

list() {
  { list_tmux; list_zoxide; } | awk 'NF && !seen[$0]++'
}

connect() {
  local target="${1:-}" name path
  [[ -z "$target" ]] && exit 0

  [[ "$target" == "~" || "$target" == "~/"* ]] && target="${HOME}${target#\~}"

  if command -v cygpath >/dev/null 2>&1 && [[ "$target" =~ ^[A-Za-z]:[/\\] ]]; then
    target=$(cygpath -u "$target")
  fi

  if [[ -d "$target" ]]; then
    path="$target"
    name=$(sanitize "$(basename "$path")")
  else
    name="$target"; path="$HOME"
  fi

  if ! tmux has-session -t="$name" 2>/dev/null; then
    TMUX="" tmux new-session -ds "$name" -c "$path"
  fi
  if [[ -n "${TMUX:-}" ]]; then
    tmux switch-client -t "$name"
  else
    tmux attach -t "$name"
  fi
}

case "${1:-pick}" in
  list) list ;;
  list-tmux) list_tmux ;;
  list-zoxide) list_zoxide ;;
  connect) shift; connect "${1:-}" ;;
  pick)
    export SESH_SCRIPT="$0"
    choice=$(FZF_DEFAULT_COMMAND="bash $SESH_SCRIPT list" fzf --reverse --prompt='⚡ ' \
      --bind "ctrl-t:change-prompt(🪟 )+reload(bash $SESH_SCRIPT list-tmux)" \
      --bind "ctrl-x:change-prompt(📁 )+reload(bash $SESH_SCRIPT list-zoxide)" \
      --bind "ctrl-a:change-prompt(⚡ )+reload(bash $SESH_SCRIPT list)" \
      --bind "ctrl-d:execute-silent(tmux kill-session -t {} 2>/dev/null)+reload(bash $SESH_SCRIPT list)")
    connect "$choice"
    ;;
esac
