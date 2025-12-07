# ROM Naming Guide

This guide covers supported ROM formats and naming conventions for each system.

## General Tips

- **No special characters required** - ES-DE will detect most common formats automatically
- **Subdirectories allowed** - You can organize ROMs into subfolders
- **Case insensitive** - File extensions work in upper or lower case
- **Compression** - Most systems support .zip and .7z compressed ROMs

---

## PlayStation 1

**Directory:** `roms/psx/`

### Supported Formats

| Format | Extension | Notes |
|--------|-----------|-------|
| BIN/CUE | `.bin` + `.cue` | Most common format |
| ISO | `.iso` | Single-file disc image |
| CHD | `.chd` | Compressed, recommended |
| PBP | `.pbp` | PSP eboot format |
| ECM | `.ecm` | Compressed format |
| M3U | `.m3u` | Multi-disc playlist |

### Multi-Disc Games

For multi-disc games, create an `.m3u` playlist file:

**Final Fantasy VII.m3u:**
```
Final Fantasy VII (Disc 1).chd
Final Fantasy VII (Disc 2).chd
Final Fantasy VII (Disc 3).chd
```

Place the `.m3u` file and all disc images in the same directory. ES-DE will show only the `.m3u` file.

### Recommended Format

**CHD** - Compressed, single file per disc, excellent compatibility.

Convert BIN/CUE to CHD:
```bash
chdman createcd -i game.cue -o game.chd
```

---

## PlayStation 2

**Directory:** `roms/ps2/`

### Supported Formats

| Format | Extension | Notes |
|--------|-----------|-------|
| ISO | `.iso` | Standard format |
| CHD | `.chd` | Compressed, recommended |
| CSO | `.cso` | Compressed ISO |
| GZ | `.gz` | Gzip compressed |
| BIN | `.bin` | Raw disc image |

### Multi-Disc Games

Use `.m3u` playlists same as PS1.

### Recommended Format

**CHD** or **ISO** - Best compatibility with PCSX2.

---

## Nintendo GameCube

**Directory:** `roms/gc/`

### Supported Formats

| Format | Extension | Notes |
|--------|-----------|-------|
| ISO | `.iso` | Standard format |
| GCZ | `.gcz` | Dolphin compressed |
| RVZ | `.rvz` | Modern compressed, recommended |
| CISO | `.ciso` | Compact ISO |
| GCM | `.gcm` | Raw GameCube format |
| DOL/ELF | `.dol`, `.elf` | Homebrew executables |

### Recommended Format

**RVZ** - Best compression ratio with no quality loss.

Convert ISO to RVZ using Dolphin:
1. Open Dolphin
2. Right-click game → Convert File
3. Select RVZ format

---

## Nintendo Wii

**Directory:** `roms/wii/`

### Supported Formats

| Format | Extension | Notes |
|--------|-----------|-------|
| ISO | `.iso` | Standard format |
| WBFS | `.wbfs` | Wii Backup format |
| RVZ | `.rvz` | Modern compressed, recommended |
| WIA | `.wia` | Wii ISO Archive |
| GCZ | `.gcz` | Compressed |
| CISO | `.ciso` | Compact ISO |

### Recommended Format

**RVZ** - Best compression, preserves all data.

---

## Nintendo DS

**Directory:** `roms/nds/`

### Supported Formats

| Format | Extension | Notes |
|--------|-----------|-------|
| NDS | `.nds` | Standard format |
| APP | `.app` | DSiWare |
| BIN | `.bin` | Raw ROM |
| ZIP | `.zip` | Compressed |
| 7Z | `.7z` | Compressed |

### Recommended Format

**NDS** - Standard, universal format.

---

## Game Boy Advance

**Directory:** `roms/gba/`

### Supported Formats

| Format | Extension | Notes |
|--------|-----------|-------|
| GBA | `.gba` | Standard GBA ROM |
| AGB | `.agb` | Alternate extension |
| GB | `.gb` | Game Boy games |
| GBC | `.gbc` | Game Boy Color games |
| SGB | `.sgb` | Super Game Boy |
| ZIP | `.zip` | Compressed |
| 7Z | `.7z` | Compressed |

### Notes

mGBA plays GB, GBC, and GBA games. You can put all in the `gba/` folder or create separate `gb/` and `gbc/` folders.

---

## Nintendo Entertainment System (NES)

**Directory:** `roms/nes/`

### Supported Formats

| Format | Extension | Notes |
|--------|-----------|-------|
| NES | `.nes` | iNES/NES 2.0 format |
| FDS | `.fds` | Famicom Disk System |
| UNF/UNIF | `.unf`, `.unif` | Universal NES format |
| ZIP | `.zip` | Compressed |
| 7Z | `.7z` | Compressed |

### Recommended Format

**NES** - iNES format with header, most compatible.

---

## Super Nintendo (SNES)

**Directory:** `roms/snes/`

### Supported Formats

| Format | Extension | Notes |
|--------|-----------|-------|
| SFC | `.sfc` | Standard format |
| SMC | `.smc` | With header |
| FIG | `.fig` | Pro Fighter format |
| SWC | `.swc` | Super Wild Card |
| BS | `.bs` | Satellaview |
| ZIP | `.zip` | Compressed |
| 7Z | `.7z` | Compressed |

### Recommended Format

**SFC** - Headerless, cleanest format.

---

## Sega Genesis / Mega Drive

**Directory:** `roms/genesis/`

### Supported Formats

| Format | Extension | Notes |
|--------|-----------|-------|
| MD | `.md` | Standard Mega Drive |
| GEN | `.gen` | Genesis format |
| BIN | `.bin` | Raw ROM |
| SMD | `.smd` | Super Magic Drive |
| 68K | `.68k` | 68000 ROM |
| SGD | `.sgd` | Sega format |
| ZIP | `.zip` | Compressed |
| 7Z | `.7z` | Compressed |

### Notes

The emulator also supports Sega CD (`.chd`, `.cue`) and 32X (`.32x`) if you add those files.

---

## Nintendo 64

**Directory:** `roms/n64/`

### Supported Formats

| Format | Extension | Notes |
|--------|-----------|-------|
| Z64 | `.z64` | Big-endian, recommended |
| N64 | `.n64` | Little-endian |
| V64 | `.v64` | Byte-swapped |
| ZIP | `.zip` | Compressed |
| 7Z | `.7z` | Compressed |

### Recommended Format

**Z64** - Native format, best compatibility.

### Byte Order

N64 ROMs come in different byte orders. Most tools can convert:
```bash
# Check format
file game.n64

# Convert if needed (using ucon64)
ucon64 --z64 game.v64
```

---

## Compression Guide

### ZIP vs 7Z

| Format | Compression | Speed | Support |
|--------|-------------|-------|---------|
| ZIP | Good | Fast | Universal |
| 7Z | Excellent | Slower | Most emulators |

### When to Compress

- **Compress:** Cartridge-based systems (NES, SNES, N64, GBA)
- **Don't compress:** CD-based systems - use CHD instead

### CHD Compression

For CD-based games (PS1, PS2, Sega CD), CHD is the recommended format:
- **Single file per disc** - No more cluttered folders with multiple .bin track files
- **Preserves CD audio** - Multi-track games with CDDA audio work perfectly
- **Maintains subchannel data** - Full compatibility with emulators
- **Good compression** - Typically 50-70% of original size
- **Hides duplicates in ES-DE** - Only one entry per game instead of .bin + .cue

#### Install chdman

```bash
sudo apt install mame-tools
```

#### Basic Conversion

```bash
# Convert BIN/CUE
chdman createcd -i game.cue -o game.chd

# Convert ISO
chdman createcd -i game.iso -o game.chd
```

#### Multi-Track Games (with audio tracks)

Games like Rayman or Tekken 3 have multiple .bin files for audio tracks. The .cue file references all of them - just point chdman at the .cue:

```bash
# This works even with 50+ track files
chdman createcd -i "Rayman (Europe).cue" -o "Rayman (Europe).chd"
```

#### Standalone .bin Files (no .cue)

If you have a .bin without a matching .cue, create one first:

```bash
# Create a basic .cue file
echo 'FILE "Game Name.bin" BINARY
  TRACK 01 MODE2/2352
    INDEX 01 00:00:00' > "Game Name.cue"

# Then convert
chdman createcd -i "Game Name.cue" -o "Game Name.chd"
```

#### ECM Compressed Files

ECM files (`.bin.ecm`) need to be decompressed first:

```bash
# Install ecm-uncompress (compile from source if not in repos)
# See: https://github.com/sahlberg/fuse-unecm

# Decompress
ecm-uncompress game.bin.ecm  # Creates game.bin

# Create .cue file, then convert to CHD
```

#### Batch Conversion Script

Convert all games in a folder:

```bash
#!/bin/bash
cd /path/to/roms/psx

for cue in *.cue; do
    if [ -f "$cue" ]; then
        chd="${cue%.cue}.chd"
        if [ ! -f "$chd" ]; then
            echo "Converting: $cue"
            chdman createcd -i "$cue" -o "$chd"
        fi
    fi
done
```

#### After Conversion

Once converted to CHD, you can delete the original .bin/.cue files to save space. The CHD contains everything needed.

---

## Naming Conventions

### No-Intro Standard

The No-Intro naming convention is recommended:
```
Game Name (Region) (Version).ext
```

Examples:
```
Super Mario World (USA).sfc
Sonic the Hedgehog (Europe).md
Pokemon Red (USA, Europe) (Rev 1).gb
```

### Region Codes

| Code | Region |
|------|--------|
| USA | North America |
| Europe | PAL regions |
| Japan | Japan |
| World | Multi-region |

### Special Tags

| Tag | Meaning |
|-----|---------|
| (Rev X) | Revision number |
| (Beta) | Beta version |
| (Proto) | Prototype |
| (Unl) | Unlicensed |
| (Hack) | ROM hack |

---

## Troubleshooting

### Game doesn't appear in ES-DE
1. Check file extension matches supported formats
2. Ensure file is in correct system folder
3. Press F5 in ES-DE to rescan
4. Check ES-DE log: `~/.emulationstation/es_log.txt`

### Game won't load
1. Verify ROM isn't corrupted (check hash against databases)
2. Try uncompressing if using ZIP/7Z
3. For CD games, ensure all files referenced in .cue are present
4. Check emulator logs for specific errors

### Wrong emulator launching
1. Check `config/es-de/es_systems.xml` for system mapping
2. Ensure ROM is in the correct folder
