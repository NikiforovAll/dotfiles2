---
description: Create high-quality GIFs from video recordings using FFmpeg with interactive prompts
---

# Create Demo GIF

This skill guides you through creating optimized GIFs from video recordings using FFmpeg's two-pass palette generation approach.

## Prerequisites

- `ffmpeg` must be installed and available in PATH

## Interactive Workflow

### Step 1: Setup Temporary Directory

**Platform-agnostic temp directory:**
```bash
# Detect platform and set temp directory
if [ -n "$TMPDIR" ]; then
    TEMP_BASE="$TMPDIR"
elif [ -n "$TEMP" ]; then
    TEMP_BASE="$TEMP"
else
    TEMP_BASE="/tmp"
fi

# Create unique temp directory for this session
TEMP_DIR="${TEMP_BASE}/demo-gif-$$"
echo "📁 Proposed temp directory: $TEMP_DIR"
```

**Prompt user:**
```
Press Enter to confirm, or specify a different path:
> ___________
```

**Create and setup auto-cleanup:**
```bash
mkdir -p "$TEMP_DIR"
# Auto-cleanup on exit
trap "echo 'Cleaning up temp files...'; rm -rf '$TEMP_DIR'" EXIT
```

### Step 2: Source Video Location

**Prompt user:**
```
📹 Source video file path:
(Absolute or relative path to .mp4, .mov, .webm, etc.)
> ___________

Examples:
  ~/Downloads/recording.mp4
  ./screencast.mp4
  /path/to/video.mov
```

**Validate:**
```bash
SOURCE_VIDEO="$USER_INPUT"

if [ ! -f "$SOURCE_VIDEO" ]; then
    echo "❌ Error: File not found: $SOURCE_VIDEO"
    exit 1
fi

echo "✓ Source video: $SOURCE_VIDEO"
```

### Step 3: Output Location

**Prompt user:**
```
📂 Output location for GIF:
(Default: current directory)

💡 Hint: Consider creating a dedicated folder for demo assets:
   - ./docs/assets/      (for documentation)
   - ./demos/            (for demo files)
   - ./.github/assets/   (for README)

Press Enter for current directory, or specify path:
> ___________
```

**Setup output:**
```bash
OUTPUT_DIR="${USER_INPUT:-.}"  # Default to current directory if empty

# Create output directory if it doesn't exist
if [ ! -d "$OUTPUT_DIR" ]; then
    echo "📁 Output directory doesn't exist: $OUTPUT_DIR"
    read -p "Create it? (y/n): " CREATE_DIR
    if [ "$CREATE_DIR" = "y" ]; then
        mkdir -p "$OUTPUT_DIR"
        echo "✓ Created: $OUTPUT_DIR"
    else
        echo "❌ Cancelled"
        exit 1
    fi
fi

echo "✓ Output directory: $OUTPUT_DIR"
```

### Step 4: Output Filename

**Prompt user:**
```
📝 Output filename (without .gif extension):
> ___________

Examples:
  demo-filter-workflow
  marketplace-preview
  copy-to-user
```

```bash
OUTPUT_NAME="$USER_INPUT"
OUTPUT_FILE="${OUTPUT_DIR}/${OUTPUT_NAME}.gif"

if [ -f "$OUTPUT_FILE" ]; then
    echo "⚠️  File exists: $OUTPUT_FILE"
    read -p "Overwrite? (y/n): " OVERWRITE
    if [ "$OVERWRITE" != "y" ]; then
        echo "❌ Cancelled"
        exit 1
    fi
fi
```

### Step 5: Trim Video (Optional)

**Prompt user:**
```
✂️  Trim video? (Recommended: keep demos under 5 seconds)

Start time in seconds (press Enter to skip trimming):
> ___________

Duration in seconds (if trimming):
> ___________
```

**Trim if needed:**
```bash
if [ -n "$START_TIME" ] && [ -n "$DURATION" ]; then
    TRIMMED_VIDEO="${TEMP_DIR}/trimmed-clip.mp4"

    echo "✂️  Trimming video: start=${START_TIME}s, duration=${DURATION}s..."
    ffmpeg -ss "$START_TIME" -i "$SOURCE_VIDEO" -t "$DURATION" -c copy "$TRIMMED_VIDEO" -y

    # Use trimmed video as source
    SOURCE_VIDEO="$TRIMMED_VIDEO"
    echo "✓ Trimmed clip ready"
fi
```

### Step 6: Quality Preset

**Prompt user:**
```
🎨 Quality preset:

1. TUI (900px, 12fps) - Optimized for terminal UIs (Recommended)
2. Documentation (800px, 12fps) - High quality, readable text
3. Web (600px, 10fps) - Good balance for web/GitHub
4. Compressed (400px, 8fps) - Small file size
5. Custom - Specify your own parameters

Select preset (1-5):
> ___________
```

**Preset configurations:**
```bash
case "$PRESET" in
    1|tui)
        WIDTH=900
        FPS=12
        QUALITY="tui"
        ;;
    2|documentation)
        WIDTH=800
        FPS=12
        QUALITY="documentation"
        ;;
    3|web)
        WIDTH=600
        FPS=10
        QUALITY="web"
        ;;
    4|compressed)
        WIDTH=400
        FPS=8
        QUALITY="compressed"
        ;;
    5|custom)
        read -p "Width (px): " WIDTH
        read -p "FPS: " FPS
        QUALITY="custom"
        ;;
    *)
        echo "❌ Invalid preset"
        exit 1
        ;;
esac

echo "✓ Using preset: $QUALITY (${WIDTH}px, ${FPS}fps)"
```

### Step 7: Generate GIF

**Two-pass approach with palette generation:**

```bash
echo "🎬 Generating GIF with two-pass palette approach..."
echo "   This may take a moment..."

# Single command with palette generation
ffmpeg -i "$SOURCE_VIDEO" \
    -vf "fps=${FPS},scale=${WIDTH}:-1:flags=lanczos,split[s0][s1];[s0]palettegen[p];[s1][p]paletteuse" \
    "$OUTPUT_FILE" -y

if [ $? -eq 0 ]; then
    FILE_SIZE=$(du -h "$OUTPUT_FILE" | cut -f1)
    echo "✅ GIF created successfully!"
    echo "   📁 Location: $OUTPUT_FILE"
    echo "   📊 Size: $FILE_SIZE"

    # Generate markdown snippet
    RELATIVE_PATH=$(realpath --relative-to="." "$OUTPUT_FILE" 2>/dev/null || echo "$OUTPUT_FILE")
    echo ""
    echo "📋 Markdown snippet:"
    echo "   ![Demo]($RELATIVE_PATH)"
else
    echo "❌ Error creating GIF"
    exit 1
fi
```

## Heredoc Template for Quick Use

Save this as a reusable script:

```bash
cat > create-gif.sh << 'EOF'
#!/usr/bin/env bash
set -e

# Configuration
SOURCE_VIDEO="${1:?Usage: $0 <source_video> [output_name] [preset] [output_dir]}"
OUTPUT_NAME="${2:-demo}"
PRESET="${3:-tui}"
OUTPUT_DIR="${4:-.}"

# Temp directory
TEMP_DIR="${TMPDIR:-${TEMP:-/tmp}}/demo-gif-$$"
mkdir -p "$TEMP_DIR"
trap "rm -rf '$TEMP_DIR'" EXIT

# Output setup
mkdir -p "$OUTPUT_DIR"
OUTPUT_FILE="${OUTPUT_DIR}/${OUTPUT_NAME}.gif"

# Preset selection
case "$PRESET" in
    tui) WIDTH=900; FPS=12 ;;
    documentation) WIDTH=800; FPS=12 ;;
    web) WIDTH=600; FPS=10 ;;
    compressed) WIDTH=400; FPS=8 ;;
    *) echo "Invalid preset. Use: tui, documentation, web, or compressed"; exit 1 ;;
esac

# Generate GIF
echo "Creating GIF: $OUTPUT_FILE (${WIDTH}px, ${FPS}fps)"
ffmpeg -i "$SOURCE_VIDEO" \
    -vf "fps=${FPS},scale=${WIDTH}:-1:flags=lanczos,split[s0][s1];[s0]palettegen[p];[s1][p]paletteuse" \
    "$OUTPUT_FILE" -y

FILE_SIZE=$(du -h "$OUTPUT_FILE" | cut -f1)
echo "✅ Done! Size: $FILE_SIZE"
EOF

chmod +x create-gif.sh
```

**Usage:**
```bash
# Using TUI preset (recommended for terminal UIs)
./create-gif.sh recording.mp4 demo-filter tui ./docs/assets

# Other presets
./create-gif.sh screencast.mp4 marketplace-preview documentation ./docs/assets
./create-gif.sh tutorial.mp4 quick-demo web ./docs/assets
./create-gif.sh clip.mp4 small-demo compressed ./demos

# Default output to current directory
./create-gif.sh recording.mp4 my-demo tui
```

## Advanced: Batch Processing

Create multiple GIFs from a list:

```bash
cat > batch-create-gifs.sh << 'EOF'
#!/usr/bin/env bash

# Create multiple demo GIFs
# Format: source_video:output_name:preset

DEMOS=(
    "recordings/filter.mp4:demo-filter:tui"
    "recordings/marketplace.mp4:demo-marketplace:tui"
    "recordings/copy.mp4:demo-copy:tui"
)

OUTPUT_DIR="${1:-./docs/assets}"
mkdir -p "$OUTPUT_DIR"

for demo in "${DEMOS[@]}"; do
    IFS=':' read -r source name preset <<< "$demo"

    case "$preset" in
        tui) WIDTH=900; FPS=12 ;;
        documentation) WIDTH=800; FPS=12 ;;
        web) WIDTH=600; FPS=10 ;;
        compressed) WIDTH=400; FPS=8 ;;
    esac

    echo "📹 Processing: $name"
    ffmpeg -i "$source" \
        -vf "fps=${FPS},scale=${WIDTH}:-1:flags=lanczos,split[s0][s1];[s0]palettegen[p];[s1][p]paletteuse" \
        "${OUTPUT_DIR}/${name}.gif" -y -loglevel error

    echo "✅ Created: ${OUTPUT_DIR}/${name}.gif"
done

echo "🎉 All demos created!"
EOF

chmod +x batch-create-gifs.sh
```

**Usage:**
```bash
# Default output to ./docs/assets
./batch-create-gifs.sh

# Custom output directory
./batch-create-gifs.sh ./my-demos
```

## Quality Preset Comparison

| Preset | Width | FPS | Best For | Typical Size (3s clip) |
|--------|-------|-----|----------|------------------------|
| **TUI** | **900px** | **12fps** | **Terminal UIs, code demos** | **~800KB** |
| Documentation | 800px | 12fps | General docs, readable text | ~600KB |
| Web | 600px | 10fps | GitHub README, web | ~400KB |
| Compressed | 400px | 8fps | Quick previews | ~200KB |

### Why TUI Preset for Terminal UIs?

- **Text Readability**: 900px width ensures terminal text is crisp and legible
- **Smooth Navigation**: 12fps captures TUI keyboard navigation smoothly
- **Accurate Colors**: Two-pass palette preserves terminal color schemes
- **File Size**: Balances quality with reasonable file sizes (<1MB typically)

## Tips for Terminal UI Recordings

### Recording Best Practices

1. **Clean terminal** - Clear screen before recording (`clear`)
2. **Font size** - Increase for readability (16-18pt recommended)
3. **Window size** - Use consistent dimensions (e.g., 120x40 columns)
4. **Color scheme** - High contrast theme (light text on dark background)
5. **Pace** - Slow, deliberate keystrokes (pause 1s between actions)
6. **Duration** - Keep under 5 seconds per workflow
7. **Focus** - Show only the relevant portion of the screen

### Optimization Tips

**Reduce file size:**
- Lower resolution: 900px → 600px = ~40% reduction
- Reduce FPS: 12fps → 10fps = ~20% reduction
- Shorter duration: 5s → 3s = ~40% reduction
- Trim unnecessary beginning/end frames

**Improve quality for TUIs:**
- Use TUI preset (900px minimum for text clarity)
- Always use two-pass palette generation
- Use Lanczos scaling algorithm
- 12fps for smooth keyboard navigation animations

## Example: LazyClaude Demo Workflow

```bash
# 1. Record terminal session (using your preferred tool)

# 2. Create GIF with TUI preset
./create-gif.sh recording.mp4 demo-filter-workflow tui ./docs/assets

# 3. Verify output
ls -lh docs/assets/demo-filter-workflow.gif

# 4. Add to documentation
echo "![Filter Workflow](./assets/demo-filter-workflow.gif)" >> docs/user-guide.md
```

## Troubleshooting

**File too large (>2MB):**
```bash
# Option 1: Use web preset instead of TUI
./create-gif.sh recording.mp4 demo web ./docs/assets

# Option 2: Reduce dimensions while keeping quality
ffmpeg -i input.mp4 -vf "fps=12,scale=700:-1:flags=lanczos,split[s0][s1];[s0]palettegen[p];[s1][p]paletteuse" output.gif -y

# Option 3: Trim duration (keep under 4 seconds)
ffmpeg -ss 1 -i input.mp4 -t 3 ...
```

**Text not readable:**
```bash
# Use TUI or documentation preset (not web/compressed)
./create-gif.sh recording.mp4 demo tui ./docs/assets

# Or increase width manually
ffmpeg -i input.mp4 -vf "fps=12,scale=1000:-1:flags=lanczos,split[s0][s1];[s0]palettegen[p];[s1][p]paletteuse" output.gif -y
```

**Colors look wrong:**
```bash
# Ensure you're using palette generation (two-pass approach)
# The heredoc templates include this by default

# Verify the filter includes: split[s0][s1];[s0]palettegen[p];[s1][p]paletteuse
```

---

**Version:** 1.0.0
**Last Updated:** 2025-12-21
