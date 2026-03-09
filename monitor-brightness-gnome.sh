#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=monitor-brightness-common.sh
source "$SCRIPT_DIR/monitor-brightness-common.sh"

STATE_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/monitor-brightness-helper"
STEP=5
MIN=20
MAX=100
GNOME_TOOL="$HOME/opt/gnome-gamma-tool/gnome-gamma-tool.py"
GNOME_DISPLAY_INDEX=1

load_monitor_brightness_config

direction="$(require_direction "${1:-}")"
ensure_state_dir

state_file="$(state_file_for "gnome")"
current="$(read_current_value "$state_file")"
new_value="$(next_value "$current" "$direction")"

if [[ ! -f "$GNOME_TOOL" ]]; then
  echo "gnome-gamma-tool not found: $GNOME_TOOL" >&2
  exit 1
fi

brightness="$(python3 -c 'import sys; print(f"{int(sys.argv[1]) / 100:.3f}")' "$new_value")"

python3 "$GNOME_TOOL" -d "$GNOME_DISPLAY_INDEX" -b "$brightness" >/dev/null 2>&1
write_current_value "$state_file" "$new_value"
