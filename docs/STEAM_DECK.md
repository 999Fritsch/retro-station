# Steam Deck Installation Guide

This guide covers installing and using Retro Station on Steam Deck.

## Prerequisites

- Steam Deck running SteamOS 3.x
- Desktop Mode access (for initial setup)
- Internet connection for downloading AppImages
- ~2GB free disk space
- Your own BIOS files (for systems that require them)
- Your own ROM files

## Installation

### Step 1: Switch to Desktop Mode

1. Press the **Steam** button
2. Go to **Power** > **Switch to Desktop**

### Step 2: Clone the Repository

Open **Konsole** (terminal) and run:

```bash
cd ~
git clone https://github.com/yourusername/retro-station.git
cd retro-station
```

### Step 3: Run the Installer

```bash
./install.sh
```

The installer will automatically detect Steam Deck and:
- Skip system package installation (preserves immutable filesystem)
- Verify required tools are available
- Download and configure all emulators as AppImages
- Create a desktop entry for Steam integration

### Step 4: Add to Steam Library

1. Open **Steam** (in Desktop Mode)
2. Click **Games** in the menu bar
3. Select **Add a Non-Steam Game to My Library...**
4. Find and check **Retro Station**
5. Click **Add Selected Programs**

### Step 5: Add Your Games

Copy your files to the appropriate directories:

```
~/retro-station/bios/    # BIOS files (see docs/BIOS_CHECKLIST.md)
~/retro-station/roms/    # ROM files organized by system
```

### Step 6: Return to Gaming Mode

Press the **Steam** button and select **Return to Gaming Mode**, or log out.

## Usage in Gaming Mode

1. Navigate to your **Library**
2. Find **Retro Station** (in Non-Steam section)
3. Press **A** to launch
4. Use the Steam Deck controls to navigate ES-DE and play games

## Controller Configuration

Steam Input automatically maps the Steam Deck controls. The default configuration works well for most games.

### Default Controls in ES-DE

| Button | Action |
|--------|--------|
| D-Pad / Left Stick | Navigate |
| A | Select / Confirm |
| B | Back / Cancel |
| Start | Menu |

### In-Game Controls

Each emulator has its own default mappings. Generally:
- **A/B/X/Y** map to the system's face buttons
- **L1/R1** map to shoulder buttons
- **L2/R2** map to triggers (where applicable)
- **Start + Select** often exits back to ES-DE

## Troubleshooting

### AppImages Won't Run

If you see FUSE-related errors:

```bash
# Check if FUSE is available
ls -la /dev/fuse

# If missing, you may need to enable it (rarely needed on Steam Deck)
```

### Missing Tools Warning

If the installer warns about missing tools like `7z` or `jq`:

1. These are optional for basic functionality
2. If you need them, you can temporarily unlock the filesystem:
   ```bash
   sudo steamos-readonly disable
   sudo pacman -S p7zip jq
   sudo steamos-readonly enable
   ```
3. Note: System changes may be reset by SteamOS updates

### ES-DE Not Appearing in Steam

1. Make sure you completed Step 4 (Add to Steam Library)
2. Try restarting Steam
3. Check that the desktop entry exists:
   ```bash
   cat ~/.local/share/applications/retro-station.desktop
   ```

### Games Not Showing in ES-DE

1. Verify ROMs are in the correct folders (e.g., `roms/nes/`, `roms/snes/`)
2. Check ROM file formats match expected extensions
3. In ES-DE, press **Start** > **Scrape** to refresh game lists

### Poor Performance

1. Close other applications
2. Ensure Steam Deck is plugged in (or adjust power settings)
3. Per-emulator:
   - **PCSX2/Dolphin**: Try lowering resolution in settings
   - **RetroArch**: Adjust core-specific settings

## Updating

To update Retro Station:

```bash
cd ~/retro-station
git pull
./install.sh
```

The installer is idempotent - it will only download/update what's needed.

## Preserving Your Setup

The following directories contain your personal data and are preserved across updates:
- `roms/` - Your game files
- `bios/` - Your BIOS files

Configuration files are in standard locations (`~/.config/`) and persist across SteamOS updates since they're in user space.

## Uninstalling

To remove Retro Station:

```bash
cd ~/retro-station
./uninstall.sh
```

This removes:
- AppImages
- Desktop entries
- Configuration files

Your ROMs and BIOS files are preserved.
