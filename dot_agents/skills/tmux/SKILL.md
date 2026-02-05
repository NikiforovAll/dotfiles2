---
name: tmux
description: Run dev servers and background processes in tmux windows.
allowed-tools: Bash(tmux:*)
---

# Tmux Session Manager

Run and manage background processes using tmux.

## Shell Configuration

**Always use `bash -i -c`** to load `.bashrc` aliases/functions:

```bash
# GOOD - aliases and functions work
tmux new-window -n server "bash -i -c 'npm run dev'"

# BAD - aliases won't load
tmux new-window -n server "npm run dev"
```

## Core Concepts

- **Session**: Container for windows (like a workspace)
- **Window**: Like a terminal tab (where commands run)
- **Pane**: Split within a window

**Default assumption**: Running inside tmux. Omit `-t <session>` - targets current session automatically.

## Essential Commands

### Create Window & Run Command

```bash
# New window with command (most common)
tmux new-window -n server "bash -i -c 'npm run dev'"

# With working directory
tmux new-window -n api -c /project/api "bash -i -c 'npm start'"

# Target different session (rare)
tmux new-window -t othersession -n task "bash -i -c 'command'"
```

### Capture Output

```bash
# Visible content
tmux capture-pane -t server -p

# Last N lines
tmux capture-pane -t server -p -S -50

# All history
tmux capture-pane -t server -p -S -
```

### Send Keys

```bash
# Send command
tmux send-keys -t server "npm test" Enter

# Special keys
tmux send-keys -t server C-c      # Ctrl+C (stop)
tmux send-keys -t server C-d      # Ctrl+D (EOF)
tmux send-keys -t server C-l      # Clear screen
```

### Window Management

```bash
# List windows
tmux list-windows

# Select window
tmux select-window -t server

# Kill window
tmux kill-window -t server

# Rename window
tmux rename-window -t oldname newname
```

### Session Management (when outside tmux)

```bash
# Create detached session
tmux new-session -d -s dev -n editor -c /project

# List sessions
tmux ls

# Attach to session
tmux attach -t dev

# Kill session
tmux kill-session -t dev
```

## Workflow Patterns

### Dev Server in Background

```bash
# Start
tmux new-window -n server "bash -i -c 'npm run dev'"

# Check output
tmux capture-pane -t server -p -S -20

# Stop
tmux send-keys -t server C-c
tmux kill-window -t server
```

### Multiple Services

```bash
# Start services
tmux new-window -n frontend "bash -i -c 'npm run dev'"
tmux new-window -n backend "bash -i -c 'npm run api'"
tmux new-window -n db "bash -i -c 'docker-compose up db'"

# Check all
for win in frontend backend db; do
  echo "=== $win ==="
  tmux capture-pane -t $win -p -S -10
done

# Stop all
for win in frontend backend db; do
  tmux send-keys -t $win C-c
  tmux kill-window -t $win
done
```

### Long-Running Process with Monitoring

```bash
# Start build
tmux new-window -n build "bash -i -c 'npm run build:prod'"

# Check periodically
tmux capture-pane -t build -p -S -20

# Wait for completion
while tmux list-windows -F '#W' | grep -q build; do
  sleep 5
done
echo "Build complete"
```

## Window Navigation (Keyboard)

| Action | Shortcut |
|--------|----------|
| List windows | `Ctrl+b w` |
| Next window | `Ctrl+b n` |
| Prev window | `Ctrl+b p` |
| Window by number | `Ctrl+b 0-9` |
| Last window | `Ctrl+b l` |

## Pane Management

```bash
# Split horizontally
tmux split-window -h

# Split vertically  
tmux split-window -v

# Navigate panes
tmux select-pane -L/-R/-U/-D   # or Alt+hjkl (your config)

# Kill pane
tmux kill-pane
```

## Agent Workflow

When user says "run X in background":

```bash
# Simple (assumes inside tmux)
tmux new-window -n <name> "bash -i -c '<command>'"

# With working directory
tmux new-window -n <name> -c <path> "bash -i -c '<command>'"
```

To check output later:
```bash
tmux capture-pane -t <name> -p -S -50
```

To stop:
```bash
tmux send-keys -t <name> C-c
tmux kill-window -t <name>
```

## Key Reminders

1. **Always `bash -i -c`** - For aliases/functions to work
2. **Omit `-t session`** - Current session is default when inside tmux
3. **Name windows** - Easy to target later with `-t name`
4. **Capture before kill** - Save output if needed
