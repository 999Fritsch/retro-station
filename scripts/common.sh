#!/bin/bash
#
# Retro Station - Common Helper Functions
# Shared utilities for all installation scripts
#

# Source guard - prevent multiple inclusion
[[ -n "${_COMMON_SH_LOADED:-}" ]] && return 0
_COMMON_SH_LOADED=1

# Color codes for output
readonly COLOR_RESET='\033[0m'
readonly COLOR_RED='\033[0;31m'
readonly COLOR_GREEN='\033[0;32m'
readonly COLOR_YELLOW='\033[0;33m'
readonly COLOR_BLUE='\033[0;34m'
readonly COLOR_CYAN='\033[0;36m'

# Logging functions
log_info() {
    echo -e "${COLOR_BLUE}[INFO]${COLOR_RESET} $*"
}

log_success() {
    echo -e "${COLOR_GREEN}[OK]${COLOR_RESET} $*"
}

log_warning() {
    echo -e "${COLOR_YELLOW}[WARN]${COLOR_RESET} $*"
}

log_error() {
    echo -e "${COLOR_RED}[ERROR]${COLOR_RESET} $*" >&2
}

log_phase() {
    echo ""
    echo -e "${COLOR_CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${COLOR_RESET}"
    echo -e "${COLOR_CYAN}  $*${COLOR_RESET}"
    echo -e "${COLOR_CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${COLOR_RESET}"
    echo ""
}

# Get the project root directory
# Returns the absolute path to the project root
get_project_root() {
    if [ -n "$PROJECT_ROOT" ]; then
        echo "$PROJECT_ROOT"
    else
        # Fallback: resolve from this script's location
        local script_dir
        script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
        echo "$(dirname "$script_dir")"
    fi
}

# Check if a command/tool is available
# Usage: require_command <command_name>
# Returns: 0 if available, 1 if not
require_command() {
    local cmd="$1"
    if command -v "$cmd" &>/dev/null; then
        return 0
    else
        log_error "Required command not found: $cmd"
        return 1
    fi
}

# Check if work is already done (idempotency helper)
# Usage: check_already_done <description> <condition_command>
# Returns: 0 if already done (should skip), 1 if needs work
check_already_done() {
    local description="$1"
    shift
    local condition_cmd="$*"

    if eval "$condition_cmd" &>/dev/null; then
        log_info "Already done: $description"
        return 0
    fi
    return 1
}

# Download a file with retry logic
# Usage: download_file <url> <destination> [max_retries]
# Returns: 0 on success, 1 on failure
download_file() {
    local url="$1"
    local dest="$2"
    local max_retries="${3:-3}"
    local retry_delay=5
    local attempt=1

    # Check if file already exists
    if [ -f "$dest" ]; then
        log_info "File already exists: $dest"
        return 0
    fi

    log_info "Downloading: $(basename "$dest")"

    while [ $attempt -le $max_retries ]; do
        if wget --progress=bar:force -O "$dest" "$url" 2>&1; then
            log_success "Downloaded: $(basename "$dest")"
            return 0
        else
            log_warning "Download attempt $attempt/$max_retries failed"
            rm -f "$dest"  # Remove partial download

            if [ $attempt -lt $max_retries ]; then
                log_info "Retrying in ${retry_delay}s..."
                sleep $retry_delay
                retry_delay=$((retry_delay * 2))  # Exponential backoff
            fi
        fi
        attempt=$((attempt + 1))
    done

    log_error "Failed to download after $max_retries attempts: $url"
    return 1
}

# Substitute placeholders in a file
# Usage: substitute_placeholders <template_file> <output_file>
# Replaces {{PROJECT_ROOT}} with actual project root path
substitute_placeholders() {
    local template="$1"
    local output="$2"
    local project_root
    project_root="$(get_project_root)"

    if [ ! -f "$template" ]; then
        log_error "Template file not found: $template"
        return 1
    fi

    sed "s|{{PROJECT_ROOT}}|$project_root|g" "$template" > "$output"
    log_success "Generated: $output"
}

# Create directory if it doesn't exist
# Usage: ensure_directory <path>
ensure_directory() {
    local dir="$1"
    if [ ! -d "$dir" ]; then
        mkdir -p "$dir"
        log_success "Created directory: $dir"
    fi
}

# Check if running on supported Ubuntu version
# Returns: 0 if supported, 1 if not
check_ubuntu_version() {
    if [ ! -f /etc/os-release ]; then
        log_error "Cannot determine OS version (no /etc/os-release)"
        return 1
    fi

    source /etc/os-release

    if [ "$ID" != "ubuntu" ]; then
        log_warning "This script is designed for Ubuntu. Detected: $ID"
        log_warning "Proceeding anyway, but some features may not work."
        return 0
    fi

    case "$VERSION_ID" in
        "22.04"|"24.04")
            log_info "Detected Ubuntu $VERSION_ID LTS - supported"
            return 0
            ;;
        *)
            log_warning "Ubuntu $VERSION_ID detected. This script is tested on 22.04 and 24.04 LTS."
            log_warning "Proceeding anyway, but some features may not work."
            return 0
            ;;
    esac
}

# Check if we have sudo access
# Returns: 0 if sudo available, 1 if not
check_sudo() {
    if sudo -n true 2>/dev/null; then
        return 0
    elif sudo -v; then
        return 0
    else
        log_error "sudo access required but not available"
        return 1
    fi
}

# Check if a command exists (silent version)
# Usage: has_command <command_name>
# Returns: 0 if available, 1 if not
has_command() {
    command -v "$1" &>/dev/null
}

# Detect the platform type
# Returns: "steamdeck", "ubuntu", or "unknown"
detect_platform() {
    if [ ! -f /etc/os-release ]; then
        echo "unknown"
        return 0
    fi

    # Source os-release in a subshell to avoid polluting environment
    local os_id
    local os_version
    os_id=$(. /etc/os-release && echo "$ID")
    os_version=$(. /etc/os-release && echo "$VERSION_ID")

    # Steam Deck detection
    if [[ "$os_id" == "steamos" ]]; then
        echo "steamdeck"
        return 0
    fi

    # Fallback: Check for Steam Deck-specific markers
    if [[ -d "/usr/share/plymouth/themes/steamos" ]] || \
       [[ -f "/etc/steamos-release" ]]; then
        echo "steamdeck"
        return 0
    fi

    # Ubuntu detection
    if [[ "$os_id" == "ubuntu" ]]; then
        echo "ubuntu"
        return 0
    fi

    echo "unknown"
}
