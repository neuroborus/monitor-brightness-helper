#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=monitor-brightness-common.sh
source "$SCRIPT_DIR/monitor-brightness-common.sh"

STATE_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/monitor-brightness-helper"
STEP=5
MIN=20
MAX=100
KDE_OUTPUT_NAME="DP-1"
KDE_METHOD="auto"

load_monitor_brightness_config

direction="$(require_direction "${1:-}")"
ensure_state_dir

state_file="$(state_file_for "kde")"
current="$(read_current_value "$state_file")"
new_value="$(next_value "$current" "$direction")"

detect_qdbus() {
  if command -v qdbus6 >/dev/null 2>&1; then
    echo "qdbus6"
  elif command -v qdbus-qt6 >/dev/null 2>&1; then
    echo "qdbus-qt6"
  elif command -v qdbus >/dev/null 2>&1; then
    echo "qdbus"
  else
    return 1
  fi
}

apply_kscreen() {
  command -v kscreen-doctor >/dev/null 2>&1 || return 1
  kscreen-doctor "output.${KDE_OUTPUT_NAME}.brightness.${new_value}" >/dev/null 2>&1
}

apply_gamma() {
  local qdbus_cmd
  qdbus_cmd="$(detect_qdbus)" || return 1

  # KWin gamma expects RGB multipliers.
  # 100% -> 1.000, 20% -> 0.200
  local gamma
  gamma="$(python3 -c 'import sys; print(f"{int(sys.argv[1]) / 100:.3f}")' "$new_value")"

  "$qdbus_cmd" org.kde.KWin /KWin setGamma "$gamma" "$gamma" "$gamma" >/dev/null 2>&1
}

applied=0

case "$KDE_METHOD" in
  kscreen)
    if apply_kscreen; then
      applied=1
    fi
    ;;
  gamma)
    if apply_gamma; then
      applied=1
    fi
    ;;
  auto)
    if apply_kscreen; then
      applied=1
    elif apply_gamma; then
      applied=1
    fi
    ;;
  *)
    echo "Invalid KDE_METHOD: $KDE_METHOD" >&2
    exit 1
    ;;
esac

if [[ "$applied" -ne 1 ]]; then
  echo "Failed to apply brightness." >&2
  echo "Check:" >&2
  echo "  1) kscreen-doctor -o" >&2
  echo "  2) qdbus6/qdbus-qt6 availability" >&2
  echo "  3) whether KWin DBus is reachable" >&2
  exit 1
fi

write_current_value "$state_file" "$new_value"
