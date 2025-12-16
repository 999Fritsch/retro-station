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

# Required tools for Steam Deck (command names, not package names)
REQUIRED_TOOLS_STEAMDECK=(
    "curl"
    "wget"
    "unzip"
    "7z"
    "jq"
)

# Ubuntu installation function
install_dependencies_ubuntu() {
    log_info "Checking system dependencies (Ubuntu mode)..."

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

# Steam Deck installation function (no system package installation)
install_dependencies_steamdeck() {
    log_info "Checking system dependencies (Steam Deck mode)..."
    log_info "Skipping system package installation (immutable filesystem)"
    log_info "Verifying available tools..."

    local missing_tools=()
    local available_tools=()

    for tool in "${REQUIRED_TOOLS_STEAMDECK[@]}"; do
        if has_command "$tool"; then
            available_tools+=("$tool")
        else
            missing_tools+=("$tool")
        fi
    done

    # Report available tools
    if [ ${#available_tools[@]} -gt 0 ]; then
        for tool in "${available_tools[@]}"; do
            log_success "$tool is available"
        done
    fi

    # Report missing tools
    if [ ${#missing_tools[@]} -gt 0 ]; then
        echo ""
        log_warning "Missing tools: ${missing_tools[*]}"
        log_warning "Some features may be limited."
        log_info "To install missing tools on Steam Deck:"
        log_info "  1. Switch to Desktop Mode"
        log_info "  2. Open Konsole and run: sudo steamos-readonly disable"
        log_info "  3. Install via: sudo pacman -S <package>"
        log_info "  4. Re-enable read-only: sudo steamos-readonly enable"
        log_info ""
        log_info "Note: System changes may be reset by SteamOS updates."
    else
        log_success "All required tools are available"
    fi

    # Always succeed - missing tools are warnings, not errors
    return 0
}

# Main dispatcher function
install_dependencies() {
    local platform="${PLATFORM_MODE:-$(detect_platform)}"

    case "$platform" in
        steamdeck)
            install_dependencies_steamdeck
            ;;
        ubuntu|unknown|*)
            install_dependencies_ubuntu
            ;;
    esac
}

# Run if executed directly (not sourced)
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    install_dependencies
    exit $?
fi

# Run when sourced from install.sh
install_dependencies
