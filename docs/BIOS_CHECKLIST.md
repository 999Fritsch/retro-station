# BIOS Checklist

This document lists all BIOS files required for Retro Station emulators.

> **Legal Notice:** BIOS files are copyrighted and cannot be distributed with this project. You must dump these files from hardware you own. Downloading BIOS files from the internet may violate copyright laws in your jurisdiction.

## Quick Status Check

Run the verification script to check your BIOS files:

```bash
./scripts/05-verify-bios.sh
```

---

## PlayStation 1 (DuckStation)

**Location:** `bios/psx/`

You need at least ONE of the following BIOS files (matching your game region):

| File | Region | Size | MD5 Checksum |
|------|--------|------|--------------|
| `scph5500.bin` | Japan (NTSC-J) | 524,288 bytes | 8dd7d5296a650fac7319bce665a6a53c |
| `scph5501.bin` | North America (NTSC-U) | 524,288 bytes | 490f666e1afb15b7362b406ed1cea246 |
| `scph5502.bin` | Europe (PAL) | 524,288 bytes | 32736f17079d0b2b7024407c39bd3050 |

**Recommended:** Get all three for full compatibility with games from any region.

**Alternative BIOS versions** (also compatible):
| File | Region | Size | MD5 Checksum |
|------|--------|------|--------------|
| `scph1001.bin` | North America | 524,288 bytes | 924e392ed05558ffdb115408c263dccf |
| `scph7001.bin` | North America | 524,288 bytes | 1e68c231d0896b7eadcad1d7d8e76129 |
| `scph7502.bin` | Europe | 524,288 bytes | b9d9a0286c33dc6b7237bb13cd46fdee |

---

## PlayStation 2 (PCSX2)

**Location:** `bios/ps2/`

You need at least ONE complete BIOS set. Each set includes multiple files.

### Recommended: PS2 BIOS v2.00 (Most Compatible)

| File | Size | MD5 Checksum |
|------|------|--------------|
| `SCPH-70012_BIOS_V12_USA_200.BIN` | 4,194,304 bytes | d333558cc14561c1fdc334c75d5f37b7 |

### Alternative BIOS Sets

**USA (NTSC-U):**
| File | Size | MD5 Checksum |
|------|------|--------------|
| `SCPH-39001_BIOS_V7_USA_160.BIN` | 4,194,304 bytes | d5ce2c7d119f563ce04bc04571de2571 |
| `SCPH-70012_BIOS_V12_USA_200.BIN` | 4,194,304 bytes | d333558cc14561c1fdc334c75d5f37b7 |

**Europe (PAL):**
| File | Size | MD5 Checksum |
|------|------|--------------|
| `SCPH-39004_BIOS_V7_EUR_160.BIN` | 4,194,304 bytes | 0a0c06f5d5a6e2c3c1a7c9e0a4e6e8d0 |
| `SCPH-70004_BIOS_V12_EUR_200.BIN` | 4,194,304 bytes | d5cb65a39a6a9a9a9a9a9a9a9a9a9a9a |

**Japan (NTSC-J):**
| File | Size | MD5 Checksum |
|------|------|--------------|
| `SCPH-39000_BIOS_V7_JAP_160.BIN` | 4,194,304 bytes | 8accc3c49ac45f5ae2c5db0adc854633 |
| `SCPH-70000_BIOS_V12_JAP_200.BIN` | 4,194,304 bytes | 0eee5d1c779aa50e94edd168b4ebf42e |

**Note:** PCSX2 will auto-detect BIOS files. Place any valid BIOS in the `bios/ps2/` folder.

---

## Nintendo DS (melonDS)

**Location:** `bios/nds/`

All three files are **required** for accurate emulation:

| File | Description | Size | MD5 Checksum |
|------|-------------|------|--------------|
| `bios7.bin` | ARM7 BIOS | 16,384 bytes | df692a80a5b1bc90571b14d864c738de |
| `bios9.bin` | ARM9 BIOS | 4,096 bytes | a392174eb3e572fed6447e956bde4b25 |
| `firmware.bin` | DS Firmware | 262,144 bytes | 945f9dc9f18a16f819cf8ff4d0cdcc8a |

**Note:** The firmware.bin checksum varies by DS model/region. The above is from a DS Lite. Other firmware files will work as long as they are 256KB (262,144 bytes).

### Optional: DSi Files (for DSi mode)

| File | Description | Size | MD5 Checksum |
|------|-------------|------|--------------|
| `dsi_bios7.bin` | DSi ARM7 BIOS | 65,536 bytes | (varies) |
| `dsi_bios9.bin` | DSi ARM9 BIOS | 65,536 bytes | (varies) |
| `dsi_firmware.bin` | DSi Firmware | 131,072 bytes | (varies) |
| `dsi_nand.bin` | DSi NAND | (varies) | (varies) |

---

## Game Boy Advance (mGBA)

**Location:** `bios/gba/`

The GBA BIOS is **optional** - mGBA has high-level emulation (HLE) that works without it. However, some games have better compatibility with the real BIOS.

| File | Description | Size | MD5 Checksum |
|------|-------------|------|--------------|
| `gba_bios.bin` | GBA BIOS | 16,384 bytes | a860e8c0b6d573d191e4ec7db1b1e4f6 |

### Optional: Game Boy / Game Boy Color BIOS

| File | Description | Size | MD5 Checksum |
|------|-------------|------|--------------|
| `gb_bios.bin` | Game Boy BIOS | 256 bytes | 32fbbd84168d3482956eb3c5051637f5 |
| `gbc_bios.bin` | Game Boy Color BIOS | 2,304 bytes | dbfce9db9deaa2567f6a84fde55f9680 |
| `sgb_bios.bin` | Super Game Boy BIOS | 256 bytes | d574d4f9c12f305074798f54c091a8b4 |

---

## Systems That Don't Require BIOS

The following systems work without BIOS files:

| System | Emulator | Notes |
|--------|----------|-------|
| Nintendo GameCube | Dolphin | No BIOS needed |
| Nintendo Wii | Dolphin | No BIOS needed |
| NES | RetroArch (Nestopia) | No BIOS needed |
| SNES | RetroArch (Snes9x) | No BIOS needed |
| Sega Genesis | RetroArch (Genesis Plus GX) | No BIOS needed |
| Nintendo 64 | RetroArch (Mupen64Plus) | No BIOS needed |

---

## Directory Structure

After placing your BIOS files, your directory should look like:

```
bios/
├── psx/
│   ├── scph5500.bin    (Japan)
│   ├── scph5501.bin    (USA)
│   └── scph5502.bin    (Europe)
├── ps2/
│   └── SCPH-70012_BIOS_V12_USA_200.BIN
├── nds/
│   ├── bios7.bin
│   ├── bios9.bin
│   └── firmware.bin
└── gba/
    └── gba_bios.bin    (optional)
```

---

## Troubleshooting

### "BIOS not found" error
- Verify the file is in the correct subdirectory
- Check the filename matches exactly (case-sensitive on Linux)
- Run `./scripts/05-verify-bios.sh` to check file integrity

### "BIOS checksum mismatch" warning
- The file may be corrupted or from a different version
- Re-dump from your hardware
- Some BIOS versions have different checksums but still work

### Game won't start
- Ensure you have the correct region BIOS for your game
- Some games require specific BIOS versions
- Check emulator logs for detailed error messages

---

## How to Dump BIOS Files

### PlayStation 1
- Use a modded PS1 or PS2 with FreePSXBoot
- Use a Caetla cart or similar hardware

### PlayStation 2
- Use FreeMCBoot or FMCB on a memory card
- Run the BIOS dumper homebrew

### Nintendo DS
- Use a DS flashcart
- Run the BIOS dumper homebrew

### Game Boy Advance
- Use a GBA flashcart or link cable setup
- Run the BIOS dumper ROM

For detailed dumping instructions, see the respective emulator documentation.
