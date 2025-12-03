# Updating Guide

How to update emulators and components in Retro Station.

---

## Quick Update

To update a specific emulator:

```bash
# 1. Delete the old AppImage
rm appimages/DuckStation*.AppImage

# 2. Re-run the download script
./scripts/02-download-appimages.sh
```

The script will download fresh copies of any missing AppImages.

---

## Update All Emulators

To update everything at once:

```bash
# Remove all AppImages (keeps versions.txt)
rm appimages/*.AppImage

# Re-download all
./scripts/02-download-appimages.sh
```

---

## Individual Emulator Updates

### EmulationStation DE

```bash
rm appimages/EmulationStation-DE*.AppImage
./scripts/02-download-appimages.sh
```

**Release notes:** [ES-DE GitLab](https://gitlab.com/es-de/emulationstation-de/-/releases)

---

### DuckStation (PS1)

```bash
rm appimages/DuckStation*.AppImage
./scripts/02-download-appimages.sh
```

DuckStation uses rolling releases - the download script always gets the latest.

**Release notes:** [DuckStation GitHub](https://github.com/stenzek/duckstation/releases)

---

### PCSX2 (PS2)

```bash
rm appimages/pcsx2*.AppImage
./scripts/02-download-appimages.sh
```

**Note:** PCSX2 versions can have different compatibility. Check the [compatibility list](https://pcsx2.net/compatibility-list.html) if games stop working.

**Release notes:** [PCSX2 GitHub](https://github.com/PCSX2/pcsx2/releases)

---

### Dolphin (GameCube/Wii)

```bash
rm appimages/Dolphin*.AppImage
./scripts/02-download-appimages.sh
```

**Release notes:** [Dolphin Website](https://dolphin-emu.org/download/)

---

### melonDS (Nintendo DS)

```bash
rm appimages/melonDS*.AppImage
./scripts/02-download-appimages.sh
```

**Release notes:** [melonDS GitHub](https://github.com/melonDS-emu/melonDS/releases)

---

### mGBA (GBA)

```bash
rm appimages/mGBA*.AppImage
./scripts/02-download-appimages.sh
```

**Release notes:** [mGBA GitHub](https://github.com/mgba-emu/mgba/releases)

---

### RetroArch

```bash
rm appimages/RetroArch*.AppImage
./scripts/02-download-appimages.sh
```

RetroArch nightly builds are downloaded by default.

**Release notes:** [RetroArch GitHub](https://github.com/libretro/RetroArch/releases)

---

## Updating RetroArch Cores

RetroArch cores are separate from the main AppImage.

### Update all cores

```bash
# Re-run emulator configuration
./scripts/03-configure-emulators.sh
```

### Update through RetroArch UI

1. Launch RetroArch
2. Main Menu → Online Updater → Update Installed Cores

### Manual core update

```bash
# Cores are stored here
ls ~/.config/retroarch/cores/

# Delete specific core
rm ~/.config/retroarch/cores/nestopia_libretro.so

# Re-download
./scripts/03-configure-emulators.sh
```

---

## Preserving Configuration

### Before updating

Your configurations are stored in:
- `~/.local/share/duckstation/` - DuckStation
- `~/.config/PCSX2/` - PCSX2
- `~/.config/dolphin-emu/` - Dolphin
- `~/.config/melonDS/` - melonDS
- `~/.config/mgba/` - mGBA
- `~/.config/retroarch/` - RetroArch
- `~/.emulationstation/` - ES-DE

**Updating AppImages does NOT affect these configurations.**

### If you need to reset configuration

```bash
# Backup first
cp -r ~/.config/PCSX2 ~/.config/PCSX2.backup

# Re-run configuration script
./scripts/03-configure-emulators.sh
```

---

## Pinned Versions

Retro Station uses pinned versions for stability. The version URLs are in:
```
scripts/02-download-appimages.sh
```

### Checking current versions

```bash
cat appimages/versions.txt
```

### Changing versions

Edit `scripts/02-download-appimages.sh` and update the URL for the desired emulator:

```bash
# Example: Update PCSX2 version
declare -A APPIMAGES=(
    ...
    ["pcsx2"]="pcsx2-v2.1.0-linux-appimage-x64-Qt.AppImage|https://github.com/PCSX2/pcsx2/releases/download/v2.1.0/..."
    ...
)
```

---

## Version Compatibility

### Breaking changes to watch for

| Emulator | Concern |
|----------|---------|
| PCSX2 | Config format can change between major versions |
| Dolphin | Save state format may change |
| RetroArch | Core API version must match |
| ES-DE | Theme compatibility with major updates |

### Rollback procedure

If an update causes problems:

1. Check `appimages/versions.txt` for the old version
2. Download the old version manually from GitHub releases
3. Place in `appimages/` directory
4. Make executable: `chmod +x appimages/NewEmulator.AppImage`

---

## Automated Updates

### Simple cron job

Create `update-emulators.sh`:
```bash
#!/bin/bash
cd /path/to/retro-station
rm appimages/*.AppImage
./scripts/02-download-appimages.sh
```

Add to crontab for weekly updates:
```bash
crontab -e
# Add line:
0 3 * * 0 /path/to/retro-station/update-emulators.sh
```

**Warning:** Automated updates may introduce breaking changes. Manual updates are recommended for stability.

---

## Troubleshooting Updates

### Download fails

```bash
# Check network
ping github.com

# Try direct download
wget -O appimages/test.AppImage "URL_FROM_VERSIONS_TXT"
```

### New version doesn't work

1. Check release notes for breaking changes
2. Try clearing config: `rm -rf ~/.config/emulator-name`
3. Re-run configuration: `./scripts/03-configure-emulators.sh`
4. Roll back to previous version if needed

### AppImage won't run after update

```bash
# Ensure it's executable
chmod +x appimages/*.AppImage

# Check for missing libraries
ldd appimages/NewEmulator.AppImage 2>&1 | grep "not found"

# Install missing libraries
sudo apt install libfuse2
```

---

## Checking for Updates

### Manual check

Visit the release pages:
- [ES-DE Releases](https://gitlab.com/es-de/emulationstation-de/-/releases)
- [DuckStation Releases](https://github.com/stenzek/duckstation/releases)
- [PCSX2 Releases](https://github.com/PCSX2/pcsx2/releases)
- [Dolphin Downloads](https://dolphin-emu.org/download/)
- [melonDS Releases](https://github.com/melonDS-emu/melonDS/releases)
- [mGBA Releases](https://github.com/mgba-emu/mgba/releases)
- [RetroArch Releases](https://github.com/libretro/RetroArch/releases)

### Using GitHub CLI

```bash
# Install gh
sudo apt install gh

# Check latest release
gh release view --repo stenzek/duckstation
gh release view --repo PCSX2/pcsx2
```
