#!/bin/bash
#
# Retro Station - Phase 3: Configure Emulators
# Deploys configuration templates with path substitution
#

# Source common helper functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

# Create save directories for emulators
create_save_directories() {
    local project_root
    project_root="$(get_project_root)"

    log_info "Creating save directories..."

    # DuckStation saves
    ensure_directory "$project_root/saves/psx/memcards"

    # PCSX2 saves
    ensure_directory "$project_root/saves/ps2/memcards"
    ensure_directory "$project_root/saves/ps2/states"
    ensure_directory "$project_root/saves/ps2/snapshots"

    # Dolphin saves
    ensure_directory "$project_root/saves/gc"
    ensure_directory "$project_root/saves/wii/sd"
    ensure_directory "$project_root/saves/wii/nand"
    ensure_directory "$project_root/saves/dolphin/dump"
    ensure_directory "$project_root/saves/dolphin/wfs"
    ensure_directory "$project_root/saves/dolphin/resourcepacks"

    # mGBA saves
    ensure_directory "$project_root/saves/gba"
    ensure_directory "$project_root/saves/gba/states"
    ensure_directory "$project_root/saves/gba/screenshots"
    ensure_directory "$project_root/saves/gba/cheats"
    ensure_directory "$project_root/saves/gba/patches"

    # RetroArch saves
    ensure_directory "$project_root/saves/retroarch/saves"
    ensure_directory "$project_root/saves/retroarch/states"
    ensure_directory "$project_root/saves/retroarch/screenshots"

    log_success "Save directories created"
}

# Configure DuckStation
configure_duckstation() {
    local project_root
    project_root="$(get_project_root)"
    local config_dir="$HOME/.local/share/duckstation"
    local template="$project_root/config/duckstation/settings.ini"

    log_info "Configuring DuckStation..."

    if [ ! -f "$template" ]; then
        log_warning "DuckStation template not found, skipping..."
        return 0
    fi

    ensure_directory "$config_dir"
    substitute_placeholders "$template" "$config_dir/settings.ini"
    log_success "DuckStation configured"
}

# Configure PCSX2
configure_pcsx2() {
    local project_root
    project_root="$(get_project_root)"
    local config_dir="$HOME/.config/PCSX2/inis"
    local template="$project_root/config/pcsx2/PCSX2.ini"

    log_info "Configuring PCSX2..."

    if [ ! -f "$template" ]; then
        log_warning "PCSX2 template not found, skipping..."
        return 0
    fi

    ensure_directory "$config_dir"
    substitute_placeholders "$template" "$config_dir/PCSX2.ini"
    log_success "PCSX2 configured"
}

# Configure Dolphin
configure_dolphin() {
    local project_root
    project_root="$(get_project_root)"
    local config_dir="$HOME/.config/dolphin-emu"
    local template_main="$project_root/config/dolphin/Dolphin.ini"
    local template_gcpad="$project_root/config/dolphin/GCPadNew.ini"

    log_info "Configuring Dolphin..."

    if [ ! -f "$template_main" ]; then
        log_warning "Dolphin template not found, skipping..."
        return 0
    fi

    ensure_directory "$config_dir"
    substitute_placeholders "$template_main" "$config_dir/Dolphin.ini"

    if [ -f "$template_gcpad" ]; then
        cp "$template_gcpad" "$config_dir/GCPadNew.ini"
        log_success "Dolphin controller config deployed"
    fi

    log_success "Dolphin configured"
}

# Configure melonDS
configure_melonds() {
    local project_root
    project_root="$(get_project_root)"
    local config_dir="$HOME/.config/melonDS"
    local template="$project_root/config/melonds/melonDS.ini"

    log_info "Configuring melonDS..."

    if [ ! -f "$template" ]; then
        log_warning "melonDS template not found, skipping..."
        return 0
    fi

    ensure_directory "$config_dir"
    substitute_placeholders "$template" "$config_dir/melonDS.ini"
    log_success "melonDS configured"
}

# Configure mGBA
configure_mgba() {
    local project_root
    project_root="$(get_project_root)"
    local config_dir="$HOME/.config/mgba"
    local template="$project_root/config/mgba/config.ini"

    log_info "Configuring mGBA..."

    if [ ! -f "$template" ]; then
        log_warning "mGBA template not found, skipping..."
        return 0
    fi

    ensure_directory "$config_dir"
    substitute_placeholders "$template" "$config_dir/config.ini"
    log_success "mGBA configured"
}

# Configure RetroArch
configure_retroarch() {
    local project_root
    project_root="$(get_project_root)"
    local config_dir="$HOME/.config/retroarch"
    local template="$project_root/config/retroarch/retroarch.cfg"

    log_info "Configuring RetroArch..."

    if [ ! -f "$template" ]; then
        log_warning "RetroArch template not found, skipping..."
        return 0
    fi

    ensure_directory "$config_dir"
    ensure_directory "$config_dir/cores"
    ensure_directory "$config_dir/autoconfig"
    ensure_directory "$config_dir/database/rdb"
    ensure_directory "$config_dir/database/cht"
    ensure_directory "$config_dir/database/cursors"
    ensure_directory "$config_dir/assets"
    ensure_directory "$config_dir/overlay"
    ensure_directory "$config_dir/shaders"

    substitute_placeholders "$template" "$config_dir/retroarch.cfg"
    log_success "RetroArch configured"
}

# Download RetroArch cores
download_retroarch_cores() {
    local project_root
    project_root="$(get_project_root)"
    local cores_dir="$HOME/.config/retroarch/cores"
    local base_url="https://buildbot.libretro.com/nightly/linux/x86_64/latest"

    log_info "Downloading RetroArch cores..."

    ensure_directory "$cores_dir"

    # Core definitions
    local cores=(
        "nestopia_libretro.so"
        "snes9x_libretro.so"
        "genesis_plus_gx_libretro.so"
        "mupen64plus_next_libretro.so"
    )

    for core in "${cores[@]}"; do
        local url="$base_url/${core}.zip"
        local zip_dest="/tmp/${core}.zip"
        local core_dest="$cores_dir/$core"

        if [ -f "$core_dest" ]; then
            log_info "Core already exists: $core"
            continue
        fi

        log_info "Downloading core: $core"
        if wget -q -O "$zip_dest" "$url" 2>/dev/null; then
            if unzip -o -q "$zip_dest" -d "$cores_dir" 2>/dev/null; then
                rm -f "$zip_dest"
                log_success "Installed core: $core"
            else
                log_warning "Failed to extract: $core"
                rm -f "$zip_dest"
            fi
        else
            log_warning "Failed to download: $core"
        fi
    done

    log_success "RetroArch cores configured"
}

# Main configuration function
configure_emulators() {
    log_info "Configuring emulators..."

    # Create save directories first
    create_save_directories

    # Configure each emulator
    configure_duckstation
    configure_pcsx2
    configure_dolphin
    configure_melonds
    configure_mgba
    configure_retroarch

    # Download RetroArch cores
    download_retroarch_cores

    log_success "All emulators configured"
}

# Run if executed directly (not sourced)
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    configure_emulators
    exit $?
fi

# Run when sourced from install.sh
configure_emulators
