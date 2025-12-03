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
