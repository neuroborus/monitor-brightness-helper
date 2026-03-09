# Monitor Brightness Helper

## Quickstart

1. Clone the repository:

   ```bash
   git clone <repo-url>
   cd monitor-brightness-helper
   chmod +x monitor-brightness-gnome.sh monitor-brightness-kde.sh
   ```

2. Copy the shared config and edit it:

   ```bash
   mkdir -p "${XDG_CONFIG_HOME:-$HOME/.config}/monitor-brightness-helper"
   cp monitor-brightness.conf "${XDG_CONFIG_HOME:-$HOME/.config}/monitor-brightness-helper/config.sh"
   ```

3. Choose the backend script:

   ```bash
   ./monitor-brightness-gnome.sh up
   ./monitor-brightness-gnome.sh down
   ./monitor-brightness-kde.sh up
   ./monitor-brightness-kde.sh down
   ```

Both scripts use the same config file and the same logical brightness scale: `20..100` percent by default.

## What It Does

This repository contains two small Wayland helper scripts:

- `monitor-brightness-gnome.sh` for GNOME via `gnome-gamma-tool`
- `monitor-brightness-kde.sh` for KDE via `kscreen-doctor` or KWin gamma

The scripts are meant for custom shortcuts, macro keys, or encoder wheels, but they also work directly from the terminal.

## Shared Configuration

The scripts look for configuration in this order:

1. `$MONITOR_BRIGHTNESS_CONFIG`
2. `${XDG_CONFIG_HOME:-$HOME/.config}/monitor-brightness-helper/config.sh`
3. `./monitor-brightness.conf` next to the scripts

Default config:

```bash
STATE_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/monitor-brightness-helper"

STEP=5
MIN=20
MAX=100

GNOME_TOOL="$HOME/opt/gnome-gamma-tool/gnome-gamma-tool.py"
GNOME_DISPLAY_INDEX=1

KDE_OUTPUT_NAME="DP-1"
KDE_METHOD="auto"
```

Notes:

- `STEP`, `MIN`, and `MAX` are shared by both backends and are always expressed in percent.
- State is stored separately per backend in `STATE_DIR`.
- GNOME converts the percent value to the `0.000..1.000` scale expected by `gnome-gamma-tool`.

## GNOME Setup

Requirements:

- GNOME on Wayland
- `python3`
- `git`
- `gir1.2-colord-1.0`

Install dependencies:

```bash
sudo apt update
sudo apt install -y git python3 gir1.2-colord-1.0
```

Install `gnome-gamma-tool`:

```bash
mkdir -p ~/opt
cd ~/opt
git clone https://github.com/zb3/gnome-gamma-tool.git
chmod +x ~/opt/gnome-gamma-tool/gnome-gamma-tool.py
```

Choose `GNOME_DISPLAY_INDEX` by testing outputs:

```bash
python3 ~/opt/gnome-gamma-tool/gnome-gamma-tool.py -d 0 -b 0.900
python3 ~/opt/gnome-gamma-tool/gnome-gamma-tool.py -d 1 -b 0.900
python3 ~/opt/gnome-gamma-tool/gnome-gamma-tool.py -d 2 -b 0.900
```

Use the index of the monitor that actually changes brightness.

## KDE Setup

Requirements depend on the selected method:

- `kscreen-doctor` for per-output brightness
- or `qdbus6` / `qdbus-qt6` / `qdbus` for KWin gamma fallback

KDE config variables:

- `KDE_OUTPUT_NAME`: output name from `kscreen-doctor -o`
- `KDE_METHOD="kscreen"`: only `kscreen-doctor`
- `KDE_METHOD="gamma"`: only KWin gamma
- `KDE_METHOD="auto"`: try `kscreen-doctor`, then fallback to gamma

To find the output name:

```bash
kscreen-doctor -o
```

## Shortcuts

Both backends expose the same CLI:

```bash
./monitor-brightness-gnome.sh up
./monitor-brightness-gnome.sh down
./monitor-brightness-kde.sh up
./monitor-brightness-kde.sh down
```

That makes shortcut binding straightforward. Example commands:

```bash
bash -lc "$HOME/path/to/monitor-brightness-helper/monitor-brightness-gnome.sh down"
bash -lc "$HOME/path/to/monitor-brightness-helper/monitor-brightness-gnome.sh up"
```

and for KDE:

```bash
bash -lc "$HOME/path/to/monitor-brightness-helper/monitor-brightness-kde.sh down"
bash -lc "$HOME/path/to/monitor-brightness-helper/monitor-brightness-kde.sh up"
```

## Notes

- This approach is useful when DDC/CI is unavailable or unreliable.
- The scripts keep the last logical brightness value and apply deltas from there.
- If KDE fails in `auto` mode, verify both `kscreen-doctor -o` and DBus availability.
