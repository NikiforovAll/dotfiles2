#!/usr/bin/env bash
set -euo pipefail

# tmux hands a display-popup command TERM=dumb, and fzf 0.73 paints through
# terminfo, so a dumb terminal draws an empty popup. Full note in sesh.sh.
if [[ "${TERM:-dumb}" == dumb ]]; then
  export TERM=screen-256color
fi

# Keep in sync with ~/.tmux.conf. Format: section|key|action
KEYS='
sessions|prefix g|session picker: tmux sessions + zoxide dirs
sessions|prefix G|session picker, opens with preview
sessions|prefix C|new session: prompt for name and path
sessions|prefix S|switch to last session
sessions|prefix X|kill current session
sessions|prefix @|promote pane to a new session
sessions|prefix Ctrl-@|promote window to a new session
sessions|Ctrl-Alt-Left/Right|previous / next session
sessions|prefix Ctrl-s|save sessions (resurrect)
sessions|prefix Ctrl-r|restore sessions (resurrect)
windows|prefix c|new window after current, same dir
windows|Shift-Left/Right|previous / next window
windows|Alt-1..9|go to window 1..9
windows|prefix H / L|move window left / right (repeat)
panes|prefix \||split side by side, same dir
panes|prefix -|split top / bottom, same dir
panes|prefix x|kill pane, no confirm
panes|Alt-h/j/k/l|move to pane left / down / up / right
panes|prefix Alt-h/j/k/l|resize pane by 5 (repeat)
panes|prefix m|mark pane
panes|prefix t h/v/f|join marked pane here: side / below / full
agents|prefix a|Claude agent switcher
agents|prefix A|Claude agent switcher, wide
notes|prefix N|quick note to ~/notes/<session>.md
notes|prefix e|open session note in VS Code
notes|prefix f|browse notes with fzf
files|prefix y|copy ~/Downloads path(s), 15 recent (Ctrl-a all)
files|prefix P|scratch pad picker (sui) for pane dir
copy|PageUp|scroll back (enters copy mode)
copy|prefix [|enter copy mode
copy|v / y|copy mode: select / copy
copy|u / d|copy mode: half page up / down
copy|prefix ]|paste tmux buffer
misc|prefix r|reload ~/.tmux.conf
misc|prefix k|this reference
misc|prefix ?|all tmux key bindings
misc|? (in pickers)|help for picker keys
'

printf '%s\n' "$KEYS" | awk -F'|' 'NF == 3 {
  printf "\033[38;5;244m%-9s\033[0m \033[38;5;109;1m%-22s\033[0m %s\n", $1, $2, $3
}' | fzf --ansi --exact --no-sort --reverse --prompt 'keys> ' \
  --header 'type to filter · Esc to close' --bind 'enter:abort' || true
