#!/bin/bash
#
# Retro Station - Phase 6: Steam Integration
# Creates desktop entry and provides instructions for adding to Steam
#

# Source common helper functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

# Get the ES-DE AppImage path
get_esde_appimage() {
    local project_root
    project_root="$(get_project_root)"

    # Find ES-DE AppImage
    local esde_path
    esde_path=$(find "$project_root/appimages" -name "es-de*.AppImage" -o -name "ES-DE*.AppImage" 2>/dev/null | head -1)

    if [ -n "$esde_path" ] && [ -f "$esde_path" ]; then
        echo "$esde_path"
        return 0
    fi

    return 1
}

# Create the desktop entry for ES-DE
create_desktop_entry() {
    local project_root
    project_root="$(get_project_root)"

    local esde_appimage
    esde_appimage=$(get_esde_appimage)

    if [ -z "$esde_appimage" ]; then
        log_error "ES-DE AppImage not found in $project_root/appimages/"
        log_info "Run the installation first to download AppImages."
        return 1
    fi

    # Ensure applications directory exists
    local apps_dir="$HOME/.local/share/applications"
    ensure_directory "$apps_dir"

    # Determine icon path
    local icon_path="$project_root/assets/icon.png"
    if [ ! -f "$icon_path" ]; then
        # Fallback to a generic game icon if our icon doesn't exist
        icon_path="applications-games"
    fi

    # Create desktop entry
    local desktop_file="$apps_dir/retro-station.desktop"

    cat > "$desktop_file" << EOF
[Desktop Entry]
Name=Retro Station
Comment=Retro gaming frontend powered by EmulationStation DE
Exec=$esde_appimage
Icon=$icon_path
Type=Application
Categories=Game;Emulator;
Keywords=retro;gaming;emulator;emulation;
StartupNotify=true
Terminal=false
EOF

    # Make executable (some systems require this)
    chmod +x "$desktop_file"

    log_success "Created desktop entry: $desktop_file"
    return 0
}

# Display instructions for adding to Steam
show_steam_instructions() {
    echo ""
    log_info "To add Retro Station to Steam:"
    echo ""
    echo "  1. Open Steam (in Desktop Mode on Steam Deck)"
    echo "  2. Click 'Games' in the menu bar"
    echo "  3. Select 'Add a Non-Steam Game to My Library...'"
    echo "  4. Find and select 'Retro Station' in the list"
    echo "  5. Click 'Add Selected Programs'"
    echo ""
    log_info "Once added, you can launch Retro Station from Gaming Mode!"
    echo ""
    log_info "Optional: Add custom artwork in Steam:"
    echo "  - Right-click the game in your library"
    echo "  - Select 'Manage' > 'Set custom artwork'"
    echo ""
}

# Main Steam integration function
setup_steam_integration() {
    log_info "Setting up Steam integration..."

    # Only run on Steam Deck mode
    if [ "$PLATFORM_MODE" != "steamdeck" ]; then
        log_info "Steam integration is only needed on Steam Deck."
        log_info "Skipping Steam integration setup."
        return 0
    fi

    # Create desktop entry
    if ! create_desktop_entry; then
        log_warning "Failed to create desktop entry"
        return 1
    fi

    # Show instructions
    show_steam_instructions

    log_success "Steam integration setup complete"
    return 0
}

# Run if executed directly (not sourced)
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    setup_steam_integration
    exit $?
fi

# Run when sourced from install.sh
setup_steam_integration
