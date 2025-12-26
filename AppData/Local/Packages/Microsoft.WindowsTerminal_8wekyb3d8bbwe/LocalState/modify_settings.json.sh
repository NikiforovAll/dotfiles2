#!/bin/bash
# Windows Terminal settings modify script for chezmoi
# Reads current settings.json from stdin, merges essentials, outputs result
#
# Usage (manual):
#   cat settings.json | bash modify_settings.json > merged.json
#
# Usage (chezmoi):
#   Automatically called during `chezmoi apply`

set -euo pipefail

# Chezmoi source directory (works on both Windows and Unix)
CHEZMOI_SOURCE="${CHEZMOI_SOURCE_DIR:-$HOME/.local/share/chezmoi}"
ESSENTIALS="$CHEZMOI_SOURCE/AppData/Local/Packages/Microsoft.WindowsTerminal_8wekyb3d8bbwe/LocalState/essentials.json"

# Fallback to destination directory (for manual usage)
if [[ ! -f "$ESSENTIALS" ]]; then
    DEST_DIR="$HOME/AppData/Local/Packages/Microsoft.WindowsTerminal_8wekyb3d8bbwe/LocalState"
    ESSENTIALS="$DEST_DIR/essentials.json"
fi

# Check if jq is installed
if ! command -v jq &>/dev/null; then
    echo "WARNING: jq not installed, skipping Windows Terminal settings merge" >&2
    cat  # pass through unchanged
    exit 0
fi

# Check if essentials.json exists
if [[ ! -f "$ESSENTIALS" ]]; then
    echo "WARNING: essentials.json not found at $ESSENTIALS, skipping merge" >&2
    cat  # pass through unchanged
    exit 0
fi

# Read stdin into a variable (handle empty input for fresh installs)
INPUT=$(cat)
if [[ -z "$INPUT" ]]; then
    echo "WARNING: Empty input (fresh install?), creating default settings" >&2
    INPUT='{"profiles":{"defaults":{},"list":[]},"schemes":[],"actions":[],"keybindings":[]}'
fi

# Merge settings
echo "$INPUT" | jq --slurpfile ess "$ESSENTIALS" '
# Merge global settings
. + $ess[0].globalSettings |

# Set profile defaults
.profiles.defaults = $ess[0].profileDefaults |

# Replace actions and keybindings entirely
.actions = $ess[0].actions |
.keybindings = $ess[0].keybindings |

# Merge schemes: keep local schemes that are not in essentials, add essentials
.schemes = (
    [.schemes[] | select(.name as $n | $ess[0].schemes | map(.name) | index($n) | not)]
    + $ess[0].schemes
) |

# Reorder profiles: Git Bash first, PowerShell second, then others
.profiles.list = (
    # 1. Git Bash first
    [$ess[0].gitBashProfile] +
    # 2. PowerShell second (merged with essentials)
    [.profiles.list[] | select(.guid == $ess[0].powerShellProfile.guid) | . + $ess[0].powerShellProfile] +
    # 3. All other profiles
    [.profiles.list[] | select(.guid != $ess[0].gitBashProfile.guid and .guid != $ess[0].powerShellProfile.guid)]
) |

# Set Git Bash as default profile
.defaultProfile = $ess[0].gitBashProfile.guid
'
