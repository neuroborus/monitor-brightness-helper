#!/usr/bin/env bash

# Path to gnome-gamma-tool
TOOL="$HOME/opt/gnome-gamma-tool/gnome-gamma-tool.py"

# File where the "current" brightness value will be stored
STATE_FILE="$HOME/.config/monitor_brightness"

# Brightness change step
STEP=0.05

# Minimum and maximum brightness (0–1)
MIN=0.20
MAX=1.00

# Display index for gnome-gamma-tool (-d N)
# Most likely 1 for the external monitor; if the wrong screen changes,
# try 0 or 2 instead.
DISPLAY_INDEX=1

mkdir -p "$(dirname "$STATE_FILE")"

direction="$1"
if [ "$direction" != "up" ] && [ "$direction" != "down" ]; then
  echo "Usage: $0 up|down"
  exit 1
fi

current=$(cat "$STATE_FILE" 2>/dev/null || echo 1.0)

new=$(python3 - <<EOF
cur = float("$current")
step = $STEP
min_b = $MIN
max_b = $MAX
direction = "$direction"

if direction == "up":
    new = cur + step
else:
    new = cur - step

if new < min_b:
    new = min_b
if new > max_b:
    new = max_b

print(f"{new:.3f}")
EOF
)

# Apply brightness to the selected display
python3 "$TOOL" -d "$DISPLAY_INDEX" -b "$new" >/dev/null 2>&1

# Persist the new brightness value
echo "$new" > "$STATE_FILE"

