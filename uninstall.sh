#!/bin/bash
#
# Retro Station - Uninstall Script
# Removes deployed configurations and AppImages while preserving user data
#

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Colors for output
COLOR_RED='\033[0;31m'
COLOR_GREEN='\033[0;32m'
COLOR_YELLOW='\033[1;33m'
COLOR_BLUE='\033[0;34m'
COLOR_RESET='\033[0m'

# Logging functions
log_info() {
    echo -e "${COLOR_BLUE}[INFO]${COLOR_RESET} $1"
}

log_success() {
    echo -e "${COLOR_GREEN}[OK]${COLOR_RESET} $1"
}

log_warning() {
    echo -e "${COLOR_YELLOW}[WARN]${COLOR_RESET} $1"
}

log_error() {
    echo -e "${COLOR_RED}[ERROR]${COLOR_RESET} $1"
}

# Print what will be removed vs preserved
print_summary() {
    echo ""
    echo "╔════════════════════════════════════════════════════════════════╗"
    echo "║                  Retro Station Uninstaller                     ║"
    echo "╚════════════════════════════════════════════════════════════════╝"
    echo ""
    echo "This will REMOVE:"
    echo "  - AppImages in $SCRIPT_DIR/appimages/"
    echo "  - ES-DE configurations in ~/ES-DE/custom_systems/"
    echo "  - ES-DE configurations in ~/.emulationstation/ (if exists)"
    echo "  - Desktop entry ~/.local/share/applications/retro-station.desktop"
    echo "  - Media directory $SCRIPT_DIR/media/"
    echo ""
    echo "This will PRESERVE (your data is safe):"
    echo "  - ROMs in $SCRIPT_DIR/roms/"
    echo "  - BIOS files in $SCRIPT_DIR/bios/"
    echo "  - ES-DE gamelists and scraped data in ~/ES-DE/gamelists/"
    echo "  - ES-DE settings in ~/ES-DE/settings/"
    echo ""
}

# Confirmation prompt
confirm_uninstall() {
    echo -e "${COLOR_YELLOW}Are you sure you want to uninstall Retro Station? [y/N]${COLOR_RESET} "
    read -r response
    case "$response" in
        [yY][eE][sS]|[yY])
            return 0
            ;;
        *)
            return 1
            ;;
    esac
}

# Remove AppImages
remove_appimages() {
    log_info "Removing AppImages..."

    local appimages_dir="$SCRIPT_DIR/appimages"

    if [ -d "$appimages_dir" ]; then
        # Remove all AppImage files but keep the directory and .gitkeep
        find "$appimages_dir" -type f -name "*.AppImage" -delete 2>/dev/null
        find "$appimages_dir" -type f -name "*.appimage" -delete 2>/dev/null
        rm -f "$appimages_dir/versions.txt" 2>/dev/null
        log_success "AppImages removed"
    else
        log_warning "AppImages directory not found"
    fi
}

# Remove ES-DE custom configurations
remove_esde_config() {
    log_info "Removing ES-DE custom configurations..."

    # ES-DE 3.x location
    if [ -d "$HOME/ES-DE/custom_systems" ]; then
        rm -f "$HOME/ES-DE/custom_systems/es_systems.xml" 2>/dev/null
        rm -f "$HOME/ES-DE/custom_systems/es_find_rules.xml" 2>/dev/null
        log_success "Removed ES-DE 3.x custom systems"
    fi

    # Legacy ES-DE location
    if [ -d "$HOME/.emulationstation/custom_systems" ]; then
        rm -f "$HOME/.emulationstation/custom_systems/es_systems.xml" 2>/dev/null
        rm -f "$HOME/.emulationstation/custom_systems/es_find_rules.xml" 2>/dev/null
        log_success "Removed legacy ES-DE custom systems"
    fi

    if [ -f "$HOME/.emulationstation/es_settings.xml" ]; then
        rm -f "$HOME/.emulationstation/es_settings.xml" 2>/dev/null
        log_success "Removed legacy ES-DE settings"
    fi
}

# Remove desktop entry
remove_desktop_entry() {
    log_info "Removing desktop entry..."

    local desktop_file="$HOME/.local/share/applications/retro-station.desktop"

    if [ -f "$desktop_file" ]; then
        rm -f "$desktop_file"
        log_success "Desktop entry removed"
    else
        log_warning "Desktop entry not found"
    fi
}

# Remove media directories (scraped content)
remove_media() {
    log_info "Removing media directories..."

    local media_dir="$SCRIPT_DIR/media"

    if [ -d "$media_dir" ]; then
        rm -rf "$media_dir"
        log_success "Media directories removed"
    else
        log_warning "Media directory not found"
    fi
}

# Main uninstall function
uninstall() {
    print_summary

    if ! confirm_uninstall; then
        log_info "Uninstall cancelled"
        exit 0
    fi

    echo ""
    log_info "Starting uninstall..."
    echo ""

    remove_appimages
    remove_esde_config
    remove_desktop_entry
    remove_media

    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    log_success "Retro Station has been uninstalled"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "Your ROMs and BIOS files have been preserved in:"
    echo "  - $SCRIPT_DIR/roms/"
    echo "  - $SCRIPT_DIR/bios/"
    echo ""
    echo "To completely remove the project, delete the directory:"
    echo "  rm -rf $SCRIPT_DIR"
    echo ""
}

# Run uninstall
uninstall
