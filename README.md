# Retro Station

A reproducible retro gaming setup for Ubuntu and Steam Deck. Clone, run, play.

## Features

- **Single command setup** - Run `install.sh` and you're ready to game
- **10 classic systems** - PS1, PS2, GameCube, Wii, NDS, GBA, NES, SNES, Genesis, N64
- **Unified frontend** - EmulationStation Desktop Edition for seamless navigation
- **Controller-first** - Xbox controller mappings pre-configured
- **Portable** - All paths relative to project root
- **Idempotent** - Safe to run installation multiple times
- **Steam Deck ready** - Automatic detection, Gaming Mode integration

## Supported Systems

| System | Emulator | BIOS Required |
|--------|----------|---------------|
| PlayStation 1 | DuckStation | Yes |
| PlayStation 2 | PCSX2 | Yes |
| GameCube | Dolphin | No |
| Wii | Dolphin | No |
| Nintendo DS | melonDS | Yes |
| Game Boy Advance | mGBA | Optional |
| NES | RetroArch (Nestopia) | No |
| SNES | RetroArch (Snes9x) | No |
| Sega Genesis | RetroArch (Genesis Plus GX) | No |
| Nintendo 64 | RetroArch (ParaLLEl N64) | No |

## Quick Start

### 1. Clone and Install

```bash
git clone https://github.com/yourusername/retro-station.git
cd retro-station
./install.sh
```

### 2. Add BIOS Files

Check which BIOS files you need:
```bash
./scripts/05-verify-bios.sh
```

Place BIOS files in the appropriate directories:
```
bios/
├── psx/      # PS1 BIOS (scph5501.bin, etc.)
├── ps2/      # PS2 BIOS
├── nds/      # DS BIOS (bios7.bin, bios9.bin, firmware.bin)
└── gba/      # GBA BIOS (optional)
```

See [docs/BIOS_CHECKLIST.md](docs/BIOS_CHECKLIST.md) for detailed requirements.

### 3. Add ROMs

Place your ROM files in the appropriate directories:
```
roms/
├── psx/      # .bin/.cue, .iso, .chd
├── ps2/      # .iso, .chd
├── gc/       # .iso, .gcz, .rvz
├── wii/      # .iso, .wbfs, .rvz
├── nds/      # .nds
├── gba/      # .gba
├── nes/      # .nes
├── snes/     # .sfc, .smc
├── genesis/  # .md, .gen
└── n64/      # .n64, .z64, .v64
```

See [docs/ROM_NAMING.md](docs/ROM_NAMING.md) for format details.

### 4. Launch

```bash
./appimages/EmulationStation-DE*.AppImage
```

Or use the desktop shortcut created during installation.

## Steam Deck Quick Start

### 1. Switch to Desktop Mode

Press **Steam** > **Power** > **Switch to Desktop**

### 2. Clone and Install

Open Konsole and run:
```bash
cd ~
git clone https://github.com/yourusername/retro-station.git
cd retro-station
./install.sh
```

The installer auto-detects Steam Deck and preserves the immutable filesystem.

### 3. Add to Steam

1. Open Steam (Desktop Mode)
2. **Games** > **Add a Non-Steam Game...**
3. Select **Retro Station** > **Add Selected Programs**

### 4. Add BIOS and ROMs

Same as Ubuntu - add files to `bios/` and `roms/` directories.

### 5. Play in Gaming Mode

Return to Gaming Mode. Find **Retro Station** in your library and launch!

See [docs/STEAM_DECK.md](docs/STEAM_DECK.md) for detailed instructions.

## System Requirements

### Ubuntu
- **OS:** Ubuntu 22.04 LTS or 24.04 LTS
- **Disk Space:** ~2GB for emulators + space for ROMs
- **RAM:** 8GB recommended (16GB for PS2)
- **GPU:** Vulkan-capable graphics card recommended
- **Controller:** Xbox controller (wired or wireless with adapter)

### Steam Deck
- **OS:** SteamOS 3.x
- **Mode:** Desktop Mode required for installation
- **Disk Space:** ~2GB for emulators + space for ROMs
- **Storage:** Internal SSD or SD card

## Usage

### Navigation (Controller)

| Button | Action |
|--------|--------|
| D-Pad / Left Stick | Navigate menus |
| A | Select / Confirm |
| B | Back / Cancel |
| Start | Open game options |
| Select | Open main menu |

### In-Game Hotkeys

Most emulators use similar hotkey patterns:

| Hotkey | Action |
|--------|--------|
| Select + Start | Exit game |
| F1 | Open emulator menu |
| F2 | Save state |
| F4 | Load state |
| F11 | Toggle fullscreen |
| Escape | Pause / Menu |

### Scraping Game Art

ES-DE can download box art, screenshots, and metadata:

1. In ES-DE, press Start to open the menu
2. Go to "Scraper"
3. Select a scraper source (ScreenScraper recommended)
4. Choose "Scrape Now"

## Directory Structure

```
retro-station/
├── install.sh              # Main installation script
├── scripts/
│   ├── common.sh           # Shared helper functions
│   ├── 00-dependencies.sh  # System packages
│   ├── 01-setup-folders.sh # Directory creation
│   ├── 02-download-appimages.sh
│   ├── 03-configure-emulators.sh
│   ├── 04-configure-esde.sh
│   └── 05-verify-bios.sh   # BIOS checker
├── config/                 # Emulator config templates
├── appimages/              # Downloaded emulators
├── roms/                   # Your game files
├── bios/                   # Your BIOS files
├── saves/                  # Save files and states
└── docs/                   # Documentation
```

## Documentation

- [BIOS Checklist](docs/BIOS_CHECKLIST.md) - Required BIOS files and checksums
- [ROM Naming Guide](docs/ROM_NAMING.md) - Supported formats per system
- [Steam Deck Guide](docs/STEAM_DECK.md) - Steam Deck installation and usage
- [Troubleshooting](docs/TROUBLESHOOTING.md) - Common issues and solutions
- [Updating](docs/UPDATING.md) - How to update emulators

## Troubleshooting

### AppImage won't run
```bash
sudo apt install libfuse2
```

### Games not appearing in ES-DE
- Check ROM file format (see ROM_NAMING.md)
- Ensure files are in correct subdirectory
- Press F5 in ES-DE to rescan

### Controller not working
- Ensure controller is connected before launching
- Check that it's recognized: `ls /dev/input/js*`

See [docs/TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md) for more solutions.

## Updating

To update emulators:
```bash
# Delete the AppImage you want to update
rm appimages/DuckStation*.AppImage

# Re-run the download script
./scripts/02-download-appimages.sh
```

See [docs/UPDATING.md](docs/UPDATING.md) for detailed instructions.

## Contributing

Contributions are welcome! Please:
1. Test on a fresh Ubuntu installation
2. Ensure idempotency (scripts can run multiple times)
3. Follow existing code style

## Legal Notice

This project does not include or distribute any copyrighted BIOS files or ROM files. You must provide your own files dumped from hardware you own.

## License

MIT License - See LICENSE file for details.
