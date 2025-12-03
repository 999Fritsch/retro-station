#!/bin/bash
#
# Retro Station - Phase 4: Configure EmulationStation DE
# Deploys ES-DE configuration with custom system definitions and launch commands
#

# Source common helper functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

# ES-DE configuration directory
# ES-DE 3.x uses ~/ES-DE, older versions use ~/.emulationstation
if [ -d "$HOME/ES-DE" ]; then
    ESDE_CONFIG_DIR="$HOME/ES-DE"
    ESDE_SETTINGS_DIR="$HOME/ES-DE/settings"
else
    ESDE_CONFIG_DIR="$HOME/.emulationstation"
    ESDE_SETTINGS_DIR="$HOME/.emulationstation"
fi

# Create media directories for scraped content
create_media_directories() {
    local project_root
    project_root="$(get_project_root)"

    log_info "Creating media directories for scraped content..."

    local systems=("psx" "ps2" "gc" "wii" "nds" "gba" "nes" "snes" "genesis" "n64")

    for system in "${systems[@]}"; do
        ensure_directory "$project_root/media/$system/screenshots"
        ensure_directory "$project_root/media/$system/titlescreens"
        ensure_directory "$project_root/media/$system/videos"
        ensure_directory "$project_root/media/$system/covers"
        ensure_directory "$project_root/media/$system/marquees"
        ensure_directory "$project_root/media/$system/3dboxes"
    done

    log_success "Media directories created"
}

# Deploy ES-DE settings
deploy_settings() {
    local project_root
    project_root="$(get_project_root)"
    local template="$project_root/config/es-de/es_settings.xml"
    local dest="$ESDE_SETTINGS_DIR/es_settings.xml"

    log_info "Deploying ES-DE settings..."

    ensure_directory "$ESDE_SETTINGS_DIR"

    # For ES-DE 3.x, inject AlternativeEmulator settings into existing config
    if [ -d "$HOME/ES-DE" ]; then
        if [ -f "$dest" ]; then
            # Check if AlternativeEmulator settings already exist
            if ! grep -q "AlternativeEmulator_nds" "$dest"; then
                log_info "Adding default emulator settings for ES-DE 3.x..."
                # Insert after the XML declaration
                sed -i '2 a\
<string name="AlternativeEmulator_gba" value="mGBA" />\
<string name="AlternativeEmulator_nds" value="melonDS" />\
<string name="AlternativeEmulator_psx" value="DuckStation" />\
<string name="AlternativeEmulator_ps2" value="PCSX2" />\
<string name="AlternativeEmulator_gc" value="Dolphin" />\
<string name="AlternativeEmulator_wii" value="Dolphin" />\
<string name="AlternativeEmulator_nes" value="RetroArch Nestopia" />\
<string name="AlternativeEmulator_snes" value="RetroArch Snes9x" />\
<string name="AlternativeEmulator_genesis" value="RetroArch Genesis Plus GX" />\
<string name="AlternativeEmulator_n64" value="RetroArch Mupen64Plus" />' "$dest"
            fi
            # Update ROMDirectory if needed
            if ! grep -q "$project_root/roms" "$dest"; then
                sed -i "s|<string name=\"ROMDirectory\" value=\"[^\"]*\"|<string name=\"ROMDirectory\" value=\"$project_root/roms/\"|" "$dest"
            fi
            log_success "ES-DE settings updated"
            return 0
        fi
    fi

    # For older ES-DE or fresh install, deploy full template
    if [ ! -f "$template" ]; then
        log_warning "ES-DE settings template not found, skipping..."
        return 0
    fi

    substitute_placeholders "$template" "$dest"
    log_success "ES-DE settings deployed"
}

# Deploy custom systems configuration
deploy_systems() {
    local project_root
    project_root="$(get_project_root)"
    local template="$project_root/config/es-de/es_systems.xml"
    local dest="$ESDE_CONFIG_DIR/custom_systems/es_systems.xml"

    log_info "Deploying ES-DE custom systems..."

    if [ ! -f "$template" ]; then
        log_warning "ES-DE systems template not found, skipping..."
        return 0
    fi

    ensure_directory "$ESDE_CONFIG_DIR/custom_systems"
    substitute_placeholders "$template" "$dest"
    log_success "ES-DE custom systems deployed"
}

# Deploy emulator find rules
deploy_find_rules() {
    local project_root
    project_root="$(get_project_root)"
    local template="$project_root/config/es-de/es_find_rules.xml"
    local dest="$ESDE_CONFIG_DIR/custom_systems/es_find_rules.xml"

    log_info "Deploying ES-DE find rules..."

    if [ ! -f "$template" ]; then
        log_warning "ES-DE find rules template not found, skipping..."
        return 0
    fi

    ensure_directory "$ESDE_CONFIG_DIR/custom_systems"
    substitute_placeholders "$template" "$dest"
    log_success "ES-DE find rules deployed"
}

# Verify ES-DE can find all emulators
verify_emulators() {
    local project_root
    project_root="$(get_project_root)"
    local all_found=true

    log_info "Verifying emulator availability..."

    # Check each AppImage exists
    local appimages=(
        "DuckStation-x64.AppImage"
        "pcsx2-v2.3.161-linux-appimage-x64-Qt.AppImage"
        "Dolphin_Emulator-x86_64.AppImage"
        "melonDS-x86_64.AppImage"
        "mGBA-0.10.3-appimage-x64.appimage"
        "RetroArch-Linux-x86_64-Nightly.AppImage"
    )

    for appimage in "${appimages[@]}"; do
        local path="$project_root/appimages/$appimage"
        if [ -x "$path" ]; then
            log_success "Found: $appimage"
        else
            log_warning "Missing or not executable: $appimage"
            all_found=false
        fi
    done

    if [ "$all_found" = true ]; then
        return 0
    else
        log_warning "Some emulators are missing. Run Phase 2 (download-appimages.sh) first."
        return 1
    fi
}

# Create desktop entry for ES-DE
create_desktop_entry() {
    local project_root
    project_root="$(get_project_root)"
    local desktop_dir="$HOME/.local/share/applications"
    local desktop_file="$desktop_dir/retro-station.desktop"

    log_info "Creating desktop entry..."

    ensure_directory "$desktop_dir"

    # Find the ES-DE AppImage
    local esde_appimage
    esde_appimage=$(find "$project_root/appimages" -name "EmulationStation-DE*.AppImage" -type f | head -1)

    if [ -z "$esde_appimage" ]; then
        log_warning "ES-DE AppImage not found, skipping desktop entry..."
        return 0
    fi

    cat > "$desktop_file" << EOF
[Desktop Entry]
Name=Retro Station
Comment=Retro Gaming Frontend
Exec=$esde_appimage
Icon=applications-games
Terminal=false
Type=Application
Categories=Game;Emulator;
StartupWMClass=emulationstation
EOF

    chmod +x "$desktop_file"
    log_success "Desktop entry created: $desktop_file"
}

# Main configuration function
configure_esde() {
    log_info "Configuring EmulationStation DE..."

    # Create media directories
    create_media_directories

    # Deploy configuration files
    deploy_settings
    deploy_systems
    deploy_find_rules

    # Verify emulators
    verify_emulators

    # Create desktop entry
    create_desktop_entry

    log_success "EmulationStation DE configured"
    echo ""
    log_info "To launch Retro Station, run:"
    log_info "  $(get_project_root)/appimages/EmulationStation-DE*.AppImage"
}

# Run if executed directly (not sourced)
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    configure_esde
    exit $?
fi

# Run when sourced from install.sh
configure_esde
