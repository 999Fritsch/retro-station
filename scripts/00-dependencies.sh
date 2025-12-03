#!/bin/bash
#
# Retro Station - Phase 0: System Dependencies
# Installs required system packages for AppImages and emulators
#

# Source common helper functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

# Required packages for Retro Station
REQUIRED_PACKAGES=(
    "curl"
    "wget"
    "unzip"
    "p7zip-full"
    "libfuse2"
    "jq"
)

# Check if a package is installed
# Handles package renames (e.g., libfuse2 -> libfuse2t64 on Ubuntu 24.04)
is_package_installed() {
    local package="$1"

    # Direct check
    if dpkg -s "$package" &>/dev/null; then
        return 0
    fi

    # Handle libfuse2 -> libfuse2t64 rename on Ubuntu 24.04
    if [ "$package" = "libfuse2" ]; then
        if dpkg -s "libfuse2t64" &>/dev/null; then
            return 0
        fi
    fi

    return 1
}

# Get list of packages that need to be installed
get_missing_packages() {
    local missing=()
    for package in "${REQUIRED_PACKAGES[@]}"; do
        if ! is_package_installed "$package"; then
            missing+=("$package")
        fi
    done
    echo "${missing[@]}"
}

# Verify all required packages are installed
verify_packages() {
    local all_installed=true
    log_info "Verifying installed packages..."

    for package in "${REQUIRED_PACKAGES[@]}"; do
        if is_package_installed "$package"; then
            # Show actual package name for renamed packages
            if [ "$package" = "libfuse2" ] && dpkg -s "libfuse2t64" &>/dev/null; then
                log_success "$package is installed (as libfuse2t64)"
            else
                log_success "$package is installed"
            fi
        else
            log_error "$package is NOT installed"
            all_installed=false
        fi
    done

    if [ "$all_installed" = true ]; then
        return 0
    else
        return 1
    fi
}

# Main installation function
install_dependencies() {
    log_info "Checking system dependencies..."

    # Check Ubuntu version
    check_ubuntu_version || {
        log_warning "Continuing despite version warning..."
    }

    # Check sudo availability
    log_info "Checking sudo access..."
    check_sudo || {
        log_error "sudo access is required to install packages"
        return 1
    }

    # Get list of missing packages
    local missing_packages
    missing_packages=$(get_missing_packages)

    # Check if any packages need to be installed
    if [ -z "$missing_packages" ]; then
        log_success "All required packages are already installed"
        return 0
    fi

    log_info "Missing packages: $missing_packages"
    log_info "Updating package lists..."

    # Update apt cache
    if ! sudo apt-get update -qq; then
        log_error "Failed to update package lists"
        return 1
    fi

    # Install missing packages
    log_info "Installing missing packages..."
    if ! sudo apt-get install -y $missing_packages; then
        log_error "Failed to install packages"
        return 1
    fi

    # Verify installation
    echo ""
    if verify_packages; then
        log_success "All dependencies installed successfully"
        return 0
    else
        log_error "Some packages failed to install"
        return 1
    fi
}

# Run if executed directly (not sourced)
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    install_dependencies
    exit $?
fi

# Run when sourced from install.sh
install_dependencies
