---
name: tmux
description: Run dev servers and background processes in tmux windows.
allowed-tools: Bash(tmux:*)
---

# Tmux Session Manager

Run and manage background processes using tmux.

## Shell Configuration

Use `bash -i -c` only when you need shell features (pipes, `&&`, redirects) or `.bashrc` aliases/functions. If the command is a plain executable on PATH, run it directly.

```bash
# Needs wrapper - uses pipe
tmux new-window -n build "bash -i -c 'npm run dev | tee log.txt'"

# Needs wrapper - uses &&
tmux new-window -n work "bash -i -c 'cd ../other && npm start'"

# Needs wrapper - relies on alias from .bashrc
tmux new-window -n server "bash -i -c 'my-alias'"

# No wrapper needed - plain executable on PATH
tmux new-window -n claude "claude --continue"
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

## Launch Claude Code in New Tmux Session/Window

```bash
# New window in current session
tmux new-window -n "claude" "claude"

# New window with specific working directory (-c sets cwd)
tmux new-window -n "claude-api" -c /project/api "claude"

# Multi-directory access (--add-dir gives claude access to extra dirs)
tmux new-window -n "claude-multi" -c /project-a "claude --add-dir /project-b --add-dir /shared/lib"

# New detached session (from outside tmux)
tmux new-session -d -s ai -n claude -c /project "claude"

# New window resuming a past conversation
tmux new-window -n "claude-cont" "claude --continue"

# New window with initial prompt
tmux new-window -n "claude-task" "claude 'explain the auth flow'"
```

## Launch OpenCode in New Tmux Session/Window

```bash
# New window
tmux new-window -n "opencode" "opencode"

# With working directory
tmux new-window -n "opencode-api" -c /project/api "opencode"

# Resume last session
tmux new-window -n "opencode-cont" "opencode --continue"

# Resume specific session
tmux new-window -n "opencode-prev" "opencode --session <session-id>"

# Headless with prompt
tmux new-window -n "oc-task" "opencode run 'fix failing tests'"
```

> Note: OpenCode has no `--fork-session` CLI flag. Forking is TUI-only. Use independent sessions for parallel tmux work.

## Session Forking (Parallel Claude Code)

Fork the current Claude Code session into a new tmux pane/window. The fork gets **full conversation context** but a new session ID — both sessions are independent from that point.

### Fork Commands

```bash
# Fork into side-by-side pane (most common)
tmux split-window -h "claude --continue --fork-session"

# Fork into new window
tmux new-window -n "fork-task" "claude --continue --fork-session"

# Fork a specific past session
tmux new-window -n "fork-old" "claude --resume <session-id> --fork-session"
```

### Fork with Task (headless)

```bash
# Fire-and-forget parallel task (pipe needs wrapper)
tmux new-window -n "tests" "bash -c 'claude -p \"run and fix failing tests\" | tee results.md'"

# Multiple parallel forks (no pipe, no wrapper)
tmux new-window -n "fix-tests" "claude -p 'fix failing tests'"
tmux new-window -n "update-docs" "claude -p 'update API docs'"
```

### Fork with Context Forwarding

```bash
# Capture context from current pane, pass to new session (pipe needs wrapper)
CONTEXT=$(tmux capture-pane -p -S -200)
tmux new-window -n "sub-task" "bash -c 'echo \"$CONTEXT\" | claude -p \"Given this context, do X\"'"
```

### Fork with Git Worktrees (write-heavy parallel work)

```bash
# Create isolated worktrees to avoid conflicts
git worktree add ../feature-a feature-a
git worktree add ../feature-b feature-b

# Launch parallel sessions in each (-c sets working dir, no wrapper needed)
tmux new-window -n "feat-a" -c ../feature-a "claude"
tmux new-window -n "feat-b" -c ../feature-b "claude"
```

### Key Flags

| Flag | Purpose |
|------|---------|
| `--continue` | Resume most recent session in current dir |
| `--resume <id>` | Resume specific session by ID |
| `--fork-session` | Create new session ID (use with `--continue` or `--resume`) |
| `-p` / `--print` | Non-interactive, print response and exit |

## Key Reminders

1. **`bash -i -c` only when needed** - For pipes, `&&`, redirects, or aliases
2. **Omit `-t session`** - Current session is default when inside tmux
3. **Name windows** - Easy to target later with `-t name`
4. **Capture before kill** - Save output if needed
5. **Use `--fork-session`** - To branch off a session without mutating the original
6. **Use git worktrees** - For parallel write-heavy forks to avoid conflicts
