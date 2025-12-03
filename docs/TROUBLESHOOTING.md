# Troubleshooting Guide

Common issues and solutions for Retro Station.

---

## Installation Issues

### AppImage won't run

**Error:** "cannot execute binary file" or FUSE-related errors

**Solution:**
```bash
sudo apt install libfuse2
```

On Ubuntu 22.04+, libfuse2 is not installed by default but is required for AppImages.

---

### Permission denied on install.sh

**Error:** `bash: ./install.sh: Permission denied`

**Solution:**
```bash
chmod +x install.sh
./install.sh
```

---

### Download fails during installation

**Symptoms:** AppImage downloads fail or timeout

**Solutions:**
1. Check internet connection
2. Re-run the install script (it will skip completed downloads)
3. Manually download failed AppImages:
   ```bash
   # Check versions.txt for URLs
   cat appimages/versions.txt

   # Re-run download script
   ./scripts/02-download-appimages.sh
   ```

---

## EmulationStation DE Issues

### ES-DE won't start

**Check 1:** Verify AppImage is executable
```bash
chmod +x appimages/EmulationStation-DE*.AppImage
```

**Check 2:** Run from terminal to see errors
```bash
./appimages/EmulationStation-DE*.AppImage
```

**Check 3:** Check for missing libraries
```bash
ldd appimages/EmulationStation-DE*.AppImage 2>&1 | grep "not found"
```

---

### Games not appearing in ES-DE

**Cause 1:** Wrong file format

Check [ROM_NAMING.md](ROM_NAMING.md) for supported formats.

**Cause 2:** Files in wrong directory

Ensure ROMs are in the correct subdirectory:
```
roms/psx/    # PlayStation 1
roms/ps2/    # PlayStation 2
roms/gc/     # GameCube
# etc.
```

**Cause 3:** ES-DE hasn't scanned

Press **F5** in ES-DE to force a rescan.

**Cause 4:** Corrupted gamelist

Delete the gamelist and rescan:
```bash
rm ~/.emulationstation/gamelists/psx/gamelist.xml
# Then press F5 in ES-DE
```

---

### ES-DE shows system but no games

**Check:** File extensions are correct
```bash
# List files in ROM directory
ls -la roms/psx/

# Check supported extensions in system config
grep -A 5 "psx" ~/.emulationstation/custom_systems/es_systems.xml
```

---

## Controller Issues

### Controller not detected

**Check 1:** Controller connected before launch?

Connect the controller, then launch ES-DE.

**Check 2:** Controller recognized by system?
```bash
# List input devices
ls /dev/input/js*

# Test controller
sudo apt install joystick
jstest /dev/input/js0
```

**Check 3:** Permissions issue?
```bash
# Add user to input group
sudo usermod -a -G input $USER
# Log out and back in
```

---

### Controller works in ES-DE but not in games

Each emulator has separate controller configuration. The install script configures Xbox controllers by default.

**DuckStation:** Settings → Controllers → Controller 1
**PCSX2:** Settings → Controllers
**Dolphin:** Controllers → Configure
**RetroArch:** Settings → Input

---

### Wrong buttons mapped

**Solution:** Reconfigure in the emulator's settings menu.

Most emulators: Press F1 or Escape during gameplay to access settings.

---

## Emulator-Specific Issues

### DuckStation (PS1)

#### "No BIOS found"
Place BIOS files in `bios/psx/`:
```bash
./scripts/05-verify-bios.sh
```

#### Black screen after loading game
- Check BIOS region matches game region
- Try a different BIOS file
- Verify ROM file isn't corrupted

---

### PCSX2 (PS2)

#### "No BIOS found"
Place BIOS in `bios/ps2/`:
```bash
ls -la bios/ps2/
```

#### Poor performance
1. Enable hardware rendering: Settings → Graphics → Renderer: Vulkan
2. Enable speedhacks: Settings → Emulation → Speedhacks
3. Lower internal resolution: Settings → Graphics → Internal Resolution

#### Game crashes or freezes
1. Try different renderer (OpenGL vs Vulkan)
2. Disable speedhacks for problematic games
3. Check PCSX2 compatibility list online

---

### Dolphin (GameCube/Wii)

#### Game runs slow
1. Enable dual-core: Options → Configuration → General → Enable Dual Core
2. Use Vulkan backend: Graphics → Backend: Vulkan
3. Disable anti-aliasing

#### Controller not working in game
1. Configure controller: Controllers → Port 1 → Configure
2. Select correct device
3. Map buttons manually

#### Wii Remote not detected
Dolphin requires actual Wii Remotes or emulated input:
- Controllers → Wii Remote 1 → Emulated Wii Remote → Configure

---

### melonDS (Nintendo DS)

#### "BIOS/firmware not found"
Place all three files in `bios/nds/`:
- bios7.bin
- bios9.bin
- firmware.bin

#### Touch screen not working
- Use mouse to emulate touch
- Configure in Config → Input and Hotkeys

---

### mGBA (GBA)

#### GBA works but GB/GBC games don't
mGBA supports all Game Boy variants. Check:
- File extension is correct (.gb, .gbc, .gba)
- ROM isn't corrupted

---

### RetroArch (NES, SNES, Genesis, N64)

#### No cores found
Re-download cores:
```bash
./scripts/03-configure-emulators.sh
```

Or manually through RetroArch:
1. Main Menu → Online Updater → Core Downloader
2. Download needed cores

#### Input lag
1. Settings → Latency → Run-Ahead (set to 1-2 frames)
2. Settings → Video → VSync → Off (if screen tearing acceptable)

#### Black screen
1. Try different video driver: Settings → Driver → Video
2. Switch between Vulkan and OpenGL

---

## Performance Issues

### General slow performance

**Check 1:** Correct video driver
Most emulators run best with Vulkan:
```bash
# Check Vulkan support
vulkaninfo | head -20
```

**Check 2:** Compositor causing issues
Try disabling desktop compositor while gaming.

**Check 3:** Power management
Ensure you're not in power-saving mode:
```bash
# Check current governor
cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor

# Set to performance
sudo cpupower frequency-set -g performance
```

---

### Screen tearing

**Solution 1:** Enable VSync in emulator settings

**Solution 2:** Enable compositor's VSync:
- GNOME: Settings → Displays → Refresh Rate
- KDE: System Settings → Display → Compositor

---

## Audio Issues

### No sound

**Check 1:** System audio working?
```bash
# Test speakers
speaker-test -t sine -f 440 -c 2
```

**Check 2:** Emulator audio settings
Most emulators: Settings → Audio → Output Device

**Check 3:** PulseAudio/PipeWire running?
```bash
pactl info
```

---

### Crackling or stuttering audio

**Solutions:**
1. Increase audio buffer size in emulator settings
2. Reduce graphics settings to maintain stable framerate
3. Close other applications consuming CPU

---

## Save Issues

### Saves not persisting

**Check 1:** Save directory exists
```bash
ls -la saves/
```

**Check 2:** Write permissions
```bash
touch saves/test && rm saves/test
```

**Check 3:** Emulator configured to use project saves
Re-run configuration:
```bash
./scripts/03-configure-emulators.sh
```

---

### Can't find save states

Save states are stored in:
```
saves/
├── psx/memcards/      # PS1 memory cards
├── ps2/states/        # PS2 save states
├── gc/                # GameCube memory cards
├── gba/states/        # GBA save states
└── retroarch/states/  # RetroArch states
```

---

## Getting Help

### Check emulator logs

**ES-DE:**
```bash
cat ~/.emulationstation/es_log.txt
```

**DuckStation:**
```bash
cat ~/.local/share/duckstation/duckstation.log
```

**PCSX2:**
```bash
cat ~/.config/PCSX2/logs/emulog.txt
```

### Verify installation

Re-run the install script to check/fix issues:
```bash
./install.sh
```

### BIOS verification

```bash
./scripts/05-verify-bios.sh
```

### Community resources

- [ES-DE Documentation](https://gitlab.com/es-de/emulationstation-de)
- [DuckStation GitHub](https://github.com/stenzek/duckstation)
- [PCSX2 Wiki](https://wiki.pcsx2.net)
- [Dolphin Wiki](https://wiki.dolphin-emu.org)
- [RetroArch Docs](https://docs.libretro.com)
