# Monitor Brightness Helper (Wayland + GNOME)

This repository contains a small helper script for controlling monitor brightness
on GNOME/Wayland using [`gnome-gamma-tool`](https://github.com/zb3/gnome-gamma-tool).

The script is intended to be used with **custom hotkeys** or a **keyboard wheel/encoder**
(for example, the left knob on a Keychron Q11), but it can also be invoked directly
from the terminal.

---

## Features

- Adjusts brightness in small incremental steps.
- Works on GNOME/Wayland via `gnome-gamma-tool`.
- Stores the last brightness value in a state file.
- Can be bound to any keys (F-keys, media keys, encoder wheel, etc.).

---

## Requirements

- GNOME on Wayland (tested on Ubuntu).
- Python 3.
- `git`
- `gir1.2-colord-1.0` (required by `gnome-gamma-tool`)

Install the required packages:

```bash
sudo apt update
sudo apt install -y git python3 gir1.2-colord-1.0
```

---

## Installation

1. **Clone and set up `gnome-gamma-tool`:**

   ```bash
   mkdir -p ~/opt
   cd ~/opt
   git clone https://github.com/zb3/gnome-gamma-tool.git
   cd gnome-gamma-tool
   chmod +x gnome-gamma-tool.py
   ```

2. **Place the brightness script:**

   Save the script file as:

   ```text
   ~/.local/bin/monitor-brightness.sh
   ```

   and make it executable:

   ```bash
   chmod +x ~/.local/bin/monitor-brightness.sh
   ```

   > The script expects `gnome-gamma-tool.py` to live at:
   > `~/opt/gnome-gamma-tool/gnome-gamma-tool.py`

---

## Configuration

### Choosing the correct display index

The script uses a `DISPLAY_INDEX` (passed to `gnome-gamma-tool` as `-d N`),
so that you can specifically target your external monitor (for example, a
Samsung Odyssey G9 connected to a laptop).

You can discover the correct index by running:

```bash
python3 ~/opt/gnome-gamma-tool/gnome-gamma-tool.py -d 0 -b 0.9
python3 ~/opt/gnome-gamma-tool/gnome-gamma-tool.py -d 1 -b 0.9
python3 ~/opt/gnome-gamma-tool/gnome-gamma-tool.py -d 2 -b 0.9
```

Whichever display dims is the one you should set as `DISPLAY_INDEX`
in `monitor-brightness.sh`.

You can also tune:

- `STEP` – how much brightness changes per step (e.g. `0.05`).
- `MIN` / `MAX` – allowed brightness range (0–1).

---

## CLI usage

You can call the script directly from a terminal:

```bash
~/.local/bin/monitor-brightness.sh up
~/.local/bin/monitor-brightness.sh down
```

This is useful for quick testing before binding shortcuts.

---

## Example: binding to a keyboard wheel (Keychron Q11)

Below is a concrete example of how to integrate the script with:

- the **left encoder wheel** (rotate up/down), and
- **Fn+F1 / Fn+F2**,

so that all of them trigger the same brightness actions.

### 1. Map keys in Keychron Launcher

Open [Keychron Launcher](https://launcher.keychron.com) and select your **Q11**.

1. **Fn layer (Layer 1)**

   - Select **Layer 1** at the top.
   - Click key **F1** and on the bottom bar (`Basic` tab) assign **F15**.
   - Click key **F2** and assign **F16**.

   Now:

   - `Fn + F1` sends `F15` → brightness down.
   - `Fn + F2` sends `F16` → brightness up.

2. **Left encoder wheel**

   Still on **Layer 1**:

   - Click the left segment of the left wheel (normally `Vol-`) and assign **F15**.
   - Click the right segment of the left wheel (normally `Vol+`) and assign **F16**.

   Switch to **Layer 0** and repeat:

   - Left segment of the left wheel → **F15**.
   - Right segment of the left wheel → **F16**.

Result:

- Wheel down → `F15`
- Wheel up → `F16`
- `Fn+F1` → `F15`
- `Fn+F2` → `F16`

All of them will be treated identically by GNOME.

---

### 2. Create GNOME custom shortcuts

Open:

> **Settings → Keyboard → Keyboard Shortcuts → Custom Shortcuts**

Create two shortcuts:

#### Brightness Down

- **Name:** `Brightness Down`
- **Command:**

  ```bash
  bash -lc "$HOME/.local/bin/monitor-brightness.sh down"
  ```

- Click on the shortcut key field and **rotate the wheel down**
  (or press `Fn+F1`). GNOME should show something like `F15` as the key.

#### Brightness Up

- **Name:** `Brightness Up`
- **Command:**

  ```bash
  bash -lc "$HOME/.local/bin/monitor-brightness.sh up"
  ```

- Click on the shortcut key field and **rotate the wheel up**
  (or press `Fn+F2`). GNOME should show something like `F16`.

---

## Result

After this setup:

- Rotating the left encoder wheel adjusts the brightness of your external monitor.
- `Fn+F1` / `Fn+F2` do the same thing as the wheel.
- The script remembers the last brightness value and works reliably on GNOME/Wayland
  without relying on DDC/CI, which may not be available when using USB-C/Thunderbolt
  docks or adapters.
