#!/bin/bash
#
# Retro Station - Main Installation Script
# Clone, run, play.
#

set -e

# Resolve the project root directory (where this script lives)
SCRIPT_PATH="$(readlink -f "${BASH_SOURCE[0]}")"
PROJECT_ROOT="$(dirname "$SCRIPT_PATH")"
export PROJECT_ROOT

# Source common helper functions
source "$PROJECT_ROOT/scripts/common.sh"

# Track overall success
INSTALL_SUCCESS=true

# Show help message
show_help() {
    echo "Retro Station Installer"
    echo ""
    echo "Usage: ./install.sh [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  --steamdeck    Force Steam Deck installation mode (no system packages)"
    echo "  --ubuntu       Force Ubuntu installation mode (uses apt)"
    echo "  --help         Show this help message"
    echo ""
    echo "If no option is provided, the platform will be auto-detected."
    echo ""
    echo "Examples:"
    echo "  ./install.sh              # Auto-detect platform"
    echo "  ./install.sh --steamdeck  # Force Steam Deck mode"
    echo "  ./install.sh --ubuntu     # Force Ubuntu mode"
}

# Parse command line arguments
PLATFORM_MODE=""
while [[ $# -gt 0 ]]; do
    case $1 in
        --steamdeck)
            PLATFORM_MODE="steamdeck"
            shift
            ;;
        --ubuntu)
            PLATFORM_MODE="ubuntu"
            shift
            ;;
        --help|-h)
            show_help
            exit 0
            ;;
        *)
            log_error "Unknown option: $1"
            echo "Use --help for usage information."
            exit 1
            ;;
    esac
done

# Auto-detect platform if not specified
if [ -z "$PLATFORM_MODE" ]; then
    PLATFORM_MODE=$(detect_platform)
fi
export PLATFORM_MODE

# Cleanup function for error handling
cleanup() {
    local exit_code=$?
    if [ $exit_code -ne 0 ]; then
        INSTALL_SUCCESS=false
        log_error "Installation failed! Check the output above for details."
    fi
}
trap cleanup EXIT

# Print banner
print_banner() {
    echo ""
    echo "╔════════════════════════════════════════════════════════════════╗"
    echo "║                                                                ║"
    echo "║   ██████╗ ███████╗████████╗██████╗  ██████╗                    ║"
    echo "║   ██╔══██╗██╔════╝╚══██╔══╝██╔══██╗██╔═══██╗                   ║"
    echo "║   ██████╔╝█████╗     ██║   ██████╔╝██║   ██║                   ║"
    echo "║   ██╔══██╗██╔══╝     ██║   ██╔══██╗██║   ██║                   ║"
    echo "║   ██║  ██║███████╗   ██║   ██║  ██║╚██████╔╝                   ║"
    echo "║   ╚═╝  ╚═╝╚══════╝   ╚═╝   ╚═╝  ╚═╝ ╚═════╝                    ║"
    echo "║                                                                ║"
    echo "║   ███████╗████████╗ █████╗ ████████╗██╗ ██████╗ ███╗   ██╗     ║"
    echo "║   ██╔════╝╚══██╔══╝██╔══██╗╚══██╔══╝██║██╔═══██╗████╗  ██║     ║"
    echo "║   ███████╗   ██║   ███████║   ██║   ██║██║   ██║██╔██╗ ██║     ║"
    echo "║   ╚════██║   ██║   ██╔══██║   ██║   ██║██║   ██║██║╚██╗██║     ║"
    echo "║   ███████║   ██║   ██║  ██║   ██║   ██║╚██████╔╝██║ ╚████║     ║"
    echo "║   ╚══════╝   ╚═╝   ╚═╝  ╚═╝   ╚═╝   ╚═╝ ╚═════╝ ╚═╝  ╚═══╝     ║"
    echo "║                                                                ║"
    echo "║              Reproducible Retro Gaming for LAN Parties         ║"
    echo "╚════════════════════════════════════════════════════════════════╝"
    echo ""
}

# Main installation flow
main() {
    print_banner

    log_info "Project root: $PROJECT_ROOT"
    log_info "Platform mode: $PLATFORM_MODE"
    echo ""

    # Phase 0: System dependencies
    log_phase "Phase 0: Installing system dependencies"
    if [ -f "$PROJECT_ROOT/scripts/00-dependencies.sh" ]; then
        source "$PROJECT_ROOT/scripts/00-dependencies.sh"
    else
        log_warning "Script 00-dependencies.sh not found, skipping..."
    fi

    # Phase 1: Setup folder structure
    log_phase "Phase 1: Setting up folder structure"
    if [ -f "$PROJECT_ROOT/scripts/01-setup-folders.sh" ]; then
        source "$PROJECT_ROOT/scripts/01-setup-folders.sh"
    else
        log_warning "Script 01-setup-folders.sh not found, skipping..."
    fi

    # Phase 2: Download AppImages
    log_phase "Phase 2: Downloading AppImages"
    if [ -f "$PROJECT_ROOT/scripts/02-download-appimages.sh" ]; then
        source "$PROJECT_ROOT/scripts/02-download-appimages.sh"
    else
        log_warning "Script 02-download-appimages.sh not found, skipping..."
    fi

    # Phase 3: Configure emulators
    log_phase "Phase 3: Configuring emulators"
    if [ -f "$PROJECT_ROOT/scripts/03-configure-emulators.sh" ]; then
        source "$PROJECT_ROOT/scripts/03-configure-emulators.sh"
    else
        log_warning "Script 03-configure-emulators.sh not found, skipping..."
    fi

    # Phase 4: Configure ES-DE frontend
    log_phase "Phase 4: Configuring EmulationStation DE"
    if [ -f "$PROJECT_ROOT/scripts/04-configure-esde.sh" ]; then
        source "$PROJECT_ROOT/scripts/04-configure-esde.sh"
    else
        log_warning "Script 04-configure-esde.sh not found, skipping..."
    fi
    
    # Phase 5.1: Auto-download BIOS files
    log_phase "Phase 5.1: Downloading BIOS files"
    if [ -f "$PROJECT_ROOT/scripts/05.1-load-bios.sh" ]; then
        source "$PROJECT_ROOT/scripts/05.1-load-bios.sh"
        load_bios_files
    else
        log_warning "Script 05.1-load-bios.sh not found, skipping BIOS download..."
    fi

    # Phase 5: Verify BIOS files
    log_phase "Phase 5: Verifying BIOS files"
    if [ -f "$PROJECT_ROOT/scripts/05-verify-bios.sh" ]; then
        source "$PROJECT_ROOT/scripts/05-verify-bios.sh"
    else
        log_warning "Script 05-verify-bios.sh not found, skipping..."
    fi

    # Phase 6: Steam integration (Steam Deck only)
    if [ "$PLATFORM_MODE" = "steamdeck" ]; then
        log_phase "Phase 6: Steam Integration"
        if [ -f "$PROJECT_ROOT/scripts/06-steam-integration.sh" ]; then
            source "$PROJECT_ROOT/scripts/06-steam-integration.sh"
        else
            log_warning "Script 06-steam-integration.sh not found, skipping..."
        fi
    fi

    # Final summary
    echo ""
    echo "════════════════════════════════════════════════════════════════════"
    if [ "$INSTALL_SUCCESS" = true ]; then
        log_success "Installation complete!"
        echo ""
        log_info "Next steps:"
        echo "  1. Add your BIOS files to: $PROJECT_ROOT/bios/"
        echo "  2. Add your ROM files to:  $PROJECT_ROOT/roms/"
        echo "  3. Run: $PROJECT_ROOT/appimages/es-de*.AppImage"
        echo ""
        log_info "Run './scripts/05-verify-bios.sh' to check for missing BIOS files."
    else
        log_error "Installation completed with errors. Please check the output above."
    fi
    echo "════════════════════════════════════════════════════════════════════"
}

# Run main installation
main "$@"
