#!/usr/bin/env bash
set -euo pipefail

HOME_UNIX="$HOME"
HOME_WIN=$(command -v cygpath >/dev/null 2>&1 && cygpath -m "$HOME" || echo "$HOME")

CACHE_DIR="$HOME/.tmux/cache"

sanitize() { printf '%s' "$1" | tr ':.' '__'; }

strip_marker() { sed -E 's/^(\* |  )//'; }

list_tmux() {
  tmux list-sessions -F '#{?session_attached,* ,  }#{session_name}' 2>/dev/null \
    | sort -k1,1r -k2
}

list_zoxide() {
  zoxide query -l 2>/dev/null \
    | tr '\\' '/' \
    | sed -e "s|^${HOME_WIN}|~|" -e "s|^${HOME_UNIX}|~|"
}

list() {
  { list_tmux; list_zoxide; } | awk 'NF && !seen[$0]++'
}

# Pre-built lists let the picker paint instantly; a start:reload swaps in live
# data right after, so staleness only lasts a few frames.
refresh() {
  mkdir -p "$CACHE_DIR"
  # Debounce: resurrect restore fires session-created per restored session,
  # spawning N concurrent refreshes — expensive forks on MSYS2 (see the
  # continuum/Winsock note in .tmux.conf).
  local last now
  last=$(stat -c %Y "$CACHE_DIR/all.list" 2>/dev/null || echo 0)
  now=$(date +%s)
  (( now - last < 2 )) && return 0
  # mv can hit a Windows sharing violation if fzf holds the file open;
  # drop the temp file rather than leak it.
  local tmp
  tmp=$(mktemp "$CACHE_DIR/.tmp.XXXXXX")
  list_tmux > "$tmp" 2>/dev/null || true
  mv -f "$tmp" "$CACHE_DIR/tmux.list" 2>/dev/null || rm -f "$tmp"
  tmp=$(mktemp "$CACHE_DIR/.tmp.XXXXXX")
  list > "$tmp" 2>/dev/null || true
  mv -f "$tmp" "$CACHE_DIR/all.list" 2>/dev/null || rm -f "$tmp"
}

connect() {
  local target="${1:-}" name path
  [[ -z "$target" ]] && exit 0

  target=$(printf '%s\n' "$target" | strip_marker | sed $'s/\033\\[[0-9;]*m//g')
  target="${target% \[*\]}"

  [[ "$target" == "~" || "$target" == "~/"* ]] && target="${HOME}${target#\~}"

  if command -v cygpath >/dev/null 2>&1 && [[ "$target" =~ ^[A-Za-z]:[/\\] ]]; then
    target=$(cygpath -u "$target")
  fi

  if [[ -d "$target" ]]; then
    path="$target"
    local root
    root=$(git -C "$path" rev-parse --show-toplevel 2>/dev/null || true)
    if [[ -n "$root" ]]; then
      command -v cygpath >/dev/null 2>&1 && [[ "$root" =~ ^[A-Za-z]:[/\\] ]] && root=$(cygpath -u "$root")
      path="$root"
    fi
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

list_worktrees() {
  local target="${1:-}"
  [[ -z "$target" ]] && { list; return; }
  target=$(printf '%s\n' "$target" | strip_marker)

  if tmux has-session -t="$target" 2>/dev/null; then
    target=$(tmux display-message -p -t "$target" '#{pane_current_path}' 2>/dev/null)
  fi

  [[ "$target" == "~"* ]] && target="${HOME}${target#\~}"
  command -v cygpath >/dev/null 2>&1 && [[ "$target" =~ ^[A-Za-z]:[/\\] ]] && target=$(cygpath -u "$target")

  if [[ ! -d "$target" ]]; then list; return; fi

  local out
  out=$(git -C "$target" worktree list 2>/dev/null \
    | awk '{
        path=$1;
        branch="";
        for (i=NF; i>=2; i--) if ($i ~ /^\[.*\]$/) { branch=$i; break }
        if (branch=="") branch="[detached]";
        printf "%s \033[38;5;109m%s\033[0m\n", path, branch
      }' \
    | tr '\\' '/' \
    | sed -e "s|^${HOME_WIN}|~|" -e "s|^${HOME_UNIX}|~|" || true)
  if [[ -z "$out" ]]; then list; else printf '%s\n' "$out"; fi
}

help() {
  cat <<'EOF'
  Keybindings

  Enter       connect (switch or create session)
  Ctrl-a      show all (tmux + zoxide)
  Ctrl-t      tmux sessions only
  Ctrl-x      zoxide dirs only
  Alt-w       git worktrees of highlighted
  Ctrl-d      kill highlighted session
  Ctrl-p      toggle preview
  ?           toggle this help
  Esc         cancel
EOF
}

preview() {
  local target="${1:-}"
  [[ -z "$target" ]] && return 0
  target=$(printf '%s\n' "$target" | strip_marker)
  if tmux has-session -t="$target" 2>/dev/null; then
    tmux capture-pane -ept "$target" -p 2>/dev/null
  else
    [[ "$target" == "~"* ]] && target="${HOME}${target#\~}"
    command -v cygpath >/dev/null 2>&1 && [[ "$target" =~ ^[A-Za-z]:[/\\] ]] && target=$(cygpath -u "$target")
    [[ -d "$target" ]] && ls -la --color=never "$target" 2>/dev/null || echo "(no preview)"
  fi
}

case "${1:-pick}" in
  list) list ;;
  list-tmux) list_tmux ;;
  list-zoxide) list_zoxide ;;
  list-worktrees) shift; list_worktrees "${1:-}" ;;
  help) help ;;
  preview) shift; preview "${1:-}" ;;
  kill)
    shift
    name=$(printf '%s\n' "${1:-}" | strip_marker)
    [[ -n "$name" ]] && tmux kill-session -t "$name" 2>/dev/null
    ;;
  connect) shift; connect "${1:-}" ;;
  refresh) refresh ;;
  pick)
    export SESH_SCRIPT="$0"
    TMUX_CMD="tmux list-sessions -F '#{?session_attached,* ,  }#{session_name}' 2>/dev/null | sort -k1,1r -k2"
    ZOX_CMD="zoxide query -l 2>/dev/null | tr '\\\\' '/' | sed -e 's|^${HOME_WIN}|~|' -e 's|^${HOME_UNIX}|~|'"
    ALL_CMD="[ -s '$CACHE_DIR/all.list' ] && cat '$CACHE_DIR/all.list' || { ${TMUX_CMD}; ${ZOX_CMD}; } | awk 'NF && !seen[\$0]++'"
    SEED_CMD="[ -s '$CACHE_DIR/tmux.list' ] && cat '$CACHE_DIR/tmux.list' || ${TMUX_CMD}"
    (bash "$0" refresh >/dev/null 2>&1 &)
    choice=$(FZF_DEFAULT_COMMAND="$SEED_CMD" fzf --ansi --reverse --prompt='tmux> ' \
      --bind "start:reload($TMUX_CMD)" \
      --preview "bash $SESH_SCRIPT preview {}" \
      --preview-window='right,50%,border-left,hidden' \
      --bind "ctrl-p:change-preview(bash $SESH_SCRIPT preview {})+toggle-preview" \
      --bind "?:change-preview(bash $SESH_SCRIPT help)+toggle-preview" \
      --bind "ctrl-t:change-prompt(tmux> )+reload($TMUX_CMD)" \
      --bind "ctrl-x:change-prompt(dirs> )+reload($ZOX_CMD)" \
      --bind "ctrl-a:change-prompt(all>  )+reload($ALL_CMD)" \
      --bind "alt-w:change-prompt(tree> )+reload(bash $SESH_SCRIPT list-worktrees {})" \
      --bind "ctrl-d:execute-silent(bash $SESH_SCRIPT kill {})+reload($TMUX_CMD)")
    connect "$choice"
    ;;
esac
