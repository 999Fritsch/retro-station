#!/bin/bash
#
# Retro Station - Phase 1: Setup Folder Structure
# Creates ROM and BIOS directory hierarchy
#

# Source common helper functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

# ROM directories to create
ROM_DIRS=(
    "psx"
    "ps2"
    "gc"
    "wii"
    "nds"
    "gba"
    "nes"
    "snes"
    "genesis"
    "n64"
)

# BIOS directories to create
BIOS_DIRS=(
    "psx"
    "ps2"
    "nds"
    "gba"
)

# Create directory with .gitkeep file
create_dir_with_gitkeep() {
    local dir="$1"
    if [ ! -d "$dir" ]; then
        mkdir -p "$dir"
        log_success "Created: $dir"
    fi
    if [ ! -f "$dir/.gitkeep" ]; then
        touch "$dir/.gitkeep"
    fi
}

# Create .gitignore to ignore contents but keep structure
create_content_gitignore() {
    local dir="$1"
    local gitignore="$dir/.gitignore"

    if [ ! -f "$gitignore" ]; then
        cat > "$gitignore" << 'EOF'
# Ignore all files in this directory
*
# Except this file and .gitkeep files
!.gitignore
!.gitkeep
!*/
# And recursively apply to subdirectories
*/*
!*/.gitkeep
EOF
        log_success "Created: $gitignore"
    fi
}

# Main setup function
setup_folders() {
    local project_root
    project_root="$(get_project_root)"

    log_info "Setting up folder structure..."

    # Create ROM directories
    log_info "Creating ROM directories..."
    for rom_dir in "${ROM_DIRS[@]}"; do
        create_dir_with_gitkeep "$project_root/roms/$rom_dir"
    done

    # Create BIOS directories
    log_info "Creating BIOS directories..."
    for bios_dir in "${BIOS_DIRS[@]}"; do
        create_dir_with_gitkeep "$project_root/bios/$bios_dir"
    done

    # Ensure top-level directories have .gitkeep
    create_dir_with_gitkeep "$project_root/appimages"

    # Create .gitignore files to ignore contents
    create_content_gitignore "$project_root/roms"
    create_content_gitignore "$project_root/bios"

    log_success "Folder structure setup complete"
}

# Run if executed directly (not sourced)
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    setup_folders
    exit $?
fi

# Run when sourced from install.sh
setup_folders
