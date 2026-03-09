#!/usr/bin/env bash

resolve_script_dir() {
  cd -- "$(dirname -- "${BASH_SOURCE[1]}")" && pwd
}

load_monitor_brightness_config() {
  local script_dir config_path
  script_dir="$(resolve_script_dir)"

  if [[ -n "${MONITOR_BRIGHTNESS_CONFIG:-}" ]]; then
    config_path="$MONITOR_BRIGHTNESS_CONFIG"
  elif [[ -f "${XDG_CONFIG_HOME:-$HOME/.config}/monitor-brightness-helper/config.sh" ]]; then
    config_path="${XDG_CONFIG_HOME:-$HOME/.config}/monitor-brightness-helper/config.sh"
  else
    config_path="$script_dir/monitor-brightness.conf"
  fi

  if [[ ! -f "$config_path" ]]; then
    echo "Configuration file not found: $config_path" >&2
    exit 1
  fi

  # shellcheck disable=SC1090
  source "$config_path"
}

usage() {
  echo "Usage: $(basename "$0") up|down" >&2
}

require_direction() {
  local direction="${1:-}"

  if [[ "$direction" != "up" && "$direction" != "down" ]]; then
    usage
    exit 1
  fi

  printf '%s\n' "$direction"
}

ensure_state_dir() {
  mkdir -p "$STATE_DIR"
}

state_file_for() {
  local backend="$1"
  printf '%s/%s.state\n' "$STATE_DIR" "$backend"
}

clamp_int() {
  local value="$1"

  if (( value < MIN )); then
    value="$MIN"
  fi
  if (( value > MAX )); then
    value="$MAX"
  fi

  printf '%s\n' "$value"
}

read_current_value() {
  local state_file="$1"
  local raw_value

  if [[ -f "$state_file" ]]; then
    raw_value="$(<"$state_file")"
    if [[ "$raw_value" =~ ^[0-9]+$ ]]; then
      printf '%s\n' "$raw_value"
      return
    fi
  fi

  printf '%s\n' "$MAX"
}

next_value() {
  local current="$1"
  local direction="$2"
  local new_value

  if [[ "$direction" == "up" ]]; then
    new_value=$(( current + STEP ))
  else
    new_value=$(( current - STEP ))
  fi

  clamp_int "$new_value"
}

write_current_value() {
  local state_file="$1"
  local value="$2"

  printf '%s\n' "$value" >"$state_file"
}
