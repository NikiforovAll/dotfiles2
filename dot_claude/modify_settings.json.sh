#!/bin/bash
# Claude Code settings modify script for chezmoi
# Syncs permissions and statusLine, preserves local enabledPlugins
#
# Usage (manual):
#   cat settings.json | bash modify_settings.json.sh
#
# Usage (chezmoi):
#   Automatically called during `chezmoi apply`

set -euo pipefail

# Chezmoi source directory (works on both Windows and Unix)
CHEZMOI_SOURCE="${CHEZMOI_SOURCE_DIR:-$HOME/.local/share/chezmoi}"
ESSENTIALS="$CHEZMOI_SOURCE/dot_claude/essentials.json"

# Fallback to destination directory (for manual usage)
if [[ ! -f "$ESSENTIALS" ]]; then
    ESSENTIALS="$HOME/.claude/essentials.json"
fi

# Check if jq is installed
if ! command -v jq &>/dev/null; then
    echo "WARNING: jq not installed, skipping Claude settings merge" >&2
    cat
    exit 0
fi

# Check if essentials.json exists
if [[ ! -f "$ESSENTIALS" ]]; then
    echo "WARNING: essentials.json not found at $ESSENTIALS, skipping merge" >&2
    cat
    exit 0
fi

# Read stdin into a variable (handle empty input for fresh installs)
INPUT=$(cat)
if [[ -z "$INPUT" ]]; then
    echo "WARNING: Empty input (fresh install?), creating default settings" >&2
    INPUT='{"permissions":{"allow":[],"deny":[],"ask":[]},"enabledPlugins":{}}'
fi

# Merge settings: replace permissions and statusLine, keep enabledPlugins
echo "$INPUT" | jq --slurpfile ess "$ESSENTIALS" '
# Replace permissions entirely
.permissions = $ess[0].permissions |

# Replace statusLine entirely
.statusLine = $ess[0].statusLine
'
