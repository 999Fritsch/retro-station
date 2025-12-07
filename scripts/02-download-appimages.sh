#!/bin/bash
#
# Retro Station - Phase 2: Download AppImages
# Downloads all emulators and ES-DE frontend as AppImages
#

# Source common helper functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

# AppImage definitions: NAME|URL|FILENAME
# Using pinned versions for stability
# Updated: 2025-12-03
declare -A APPIMAGES=(
    ["esde"]="EmulationStation-DE-x64-3.4.0.AppImage|https://gitlab.com/es-de/emulationstation-de/-/package_files/246875981/download"
    ["duckstation"]="DuckStation-x64.AppImage|https://github.com/stenzek/duckstation/releases/download/latest/DuckStation-x64.AppImage"
    ["pcsx2"]="pcsx2-v2.3.161-linux-appimage-x64-Qt.AppImage|https://github.com/PCSX2/pcsx2/releases/download/v2.3.161/pcsx2-v2.3.161-linux-appimage-x64-Qt.AppImage"
    ["dolphin"]="Dolphin_Emulator-x86_64.AppImage|https://github.com/pkgforge-dev/Dolphin-emu-AppImage/releases/download/2509%402025-12-02_1764646513/Dolphin_Emulator-2509-anylinux.squashfs-x86_64.AppImage"
    ["melonds"]="melonDS-x86_64.AppImage|https://github.com/melonDS-emu/melonDS/releases/download/0.9.5/melonDS-x86_64.AppImage"
    ["mgba"]="mGBA-0.10.3-appimage-x64.appimage|https://github.com/mgba-emu/mgba/releases/download/0.10.3/mGBA-0.10.3-appimage-x64.appimage"
    ["retroarch"]="retroarch|https://buildbot.libretro.com/stable/1.22.2/linux/x86_64/RetroArch.7z"
)

# Download order (for nice output)
DOWNLOAD_ORDER=("esde" "duckstation" "pcsx2" "dolphin" "melonds" "mgba" "retroarch")

# Parse appimage definition
get_appimage_filename() {
    local def="$1"
    echo "${def%%|*}"
}

get_appimage_url() {
    local def="$1"
    echo "${def#*|}"
}

# Check if AppImage already exists and is valid
appimage_exists() {
    local filepath="$1"
    # For retroarch from 7z, check for the AppImage
    if [[ "$filepath" == */retroarch ]]; then
        local project_root
        project_root="$(get_project_root)"
        [ -f "$project_root/appimages/RetroArch.AppImage" ] && [ -x "$project_root/appimages/RetroArch.AppImage" ]
    else
        [ -f "$filepath" ] && [ -x "$filepath" ] && [ -s "$filepath" ]
    fi
}

# Download a single AppImage
download_appimage() {
    local name="$1"
    local def="${APPIMAGES[$name]}"
    local filename
    local url
    local project_root
    local dest

    filename=$(get_appimage_filename "$def")
    url=$(get_appimage_url "$def")
    project_root="$(get_project_root)"
    dest="$project_root/appimages/$filename"

    # Check if already exists
    if appimage_exists "$dest"; then
        log_info "Already exists: $filename"
        return 0
    fi

    # Check if URL is a zip file (needs extraction)
    if [[ "$url" == *.zip ]]; then
        log_info "Downloading $name (zipped): $filename"
        local zip_dest="/tmp/${name}_appimage.zip"

        if download_file "$url" "$zip_dest"; then
            log_info "Extracting AppImage from zip..."
            # Extract to appimages directory
            if unzip -o -j "$zip_dest" "*.AppImage" -d "$project_root/appimages/" 2>/dev/null; then
                # Find and rename the extracted AppImage
                local extracted
                extracted=$(find "$project_root/appimages/" -maxdepth 1 -name "*.AppImage" -newer "$zip_dest" -o -name "*melonDS*.AppImage" 2>/dev/null | head -1)
                if [ -n "$extracted" ] && [ -f "$extracted" ]; then
                    mv "$extracted" "$dest" 2>/dev/null || true
                fi
                rm -f "$zip_dest"
                chmod +x "$dest"
                log_success "Downloaded and extracted: $filename"
                return 0
            else
                log_error "Failed to extract: $filename"
                rm -f "$zip_dest"
                return 1
            fi
        else
            log_error "Failed to download: $filename"
            return 1
        fi
    fi

    # Check if URL is a 7z file (needs extraction) - used for official RetroArch
    if [[ "$url" == *.7z ]]; then
        log_info "Downloading $name (7z archive): $filename"
        local archive_dest="/tmp/${name}_archive.7z"
        local extract_dir="/tmp/${name}_extract"

        if download_file "$url" "$archive_dest"; then
            log_info "Extracting from 7z archive..."
            rm -rf "$extract_dir"
            mkdir -p "$extract_dir"

            if 7z x -o"$extract_dir" "$archive_dest" -y >/dev/null 2>&1; then
                # For RetroArch, the archive contains an AppImage
                local appimage_bin
                appimage_bin=$(find "$extract_dir" -type f -name "*.AppImage" 2>/dev/null | head -1)

                if [ -n "$appimage_bin" ] && [ -f "$appimage_bin" ]; then
                    # Copy the AppImage to appimages directory
                    local dest_appimage="$project_root/appimages/RetroArch.AppImage"
                    cp "$appimage_bin" "$dest_appimage"
                    chmod +x "$dest_appimage"

                    rm -f "$archive_dest"
                    rm -rf "$extract_dir"
                    log_success "Downloaded and extracted: RetroArch.AppImage"
                    return 0
                else
                    log_error "Could not find RetroArch AppImage in archive"
                    rm -f "$archive_dest"
                    rm -rf "$extract_dir"
                    return 1
                fi
            else
                log_error "Failed to extract 7z: $filename"
                rm -f "$archive_dest"
                return 1
            fi
        else
            log_error "Failed to download: $filename"
            return 1
        fi
    fi

    # Direct download (not zipped)
    log_info "Downloading $name: $filename"
    if download_file "$url" "$dest"; then
        chmod +x "$dest"
        log_success "Downloaded and made executable: $filename"
        return 0
    else
        log_error "Failed to download: $filename"
        return 1
    fi
}

# Create versions manifest
create_versions_manifest() {
    local project_root
    project_root="$(get_project_root)"
    local manifest="$project_root/appimages/versions.txt"

    log_info "Creating versions manifest..."

    cat > "$manifest" << EOF
# Retro Station - AppImage Versions
# Generated: $(date -Iseconds)
#
# This file documents the AppImage versions downloaded.
# To update an emulator, delete its AppImage and re-run install.sh
#

EOF

    for name in "${DOWNLOAD_ORDER[@]}"; do
        local def="${APPIMAGES[$name]}"
        local filename
        filename=$(get_appimage_filename "$def")
        local filepath="$project_root/appimages/$filename"

        if [ -f "$filepath" ]; then
            local size
            size=$(stat -c%s "$filepath" 2>/dev/null || echo "unknown")
            echo "$name: $filename ($(numfmt --to=iec-i --suffix=B $size 2>/dev/null || echo "${size} bytes"))" >> "$manifest"
        else
            echo "$name: NOT DOWNLOADED" >> "$manifest"
        fi
    done

    log_success "Created: $manifest"
}

# Verify all AppImages are present and executable
verify_appimages() {
    local project_root
    project_root="$(get_project_root)"
    local all_present=true

    log_info "Verifying AppImages..."

    for name in "${DOWNLOAD_ORDER[@]}"; do
        local def="${APPIMAGES[$name]}"
        local filename
        filename=$(get_appimage_filename "$def")
        local filepath="$project_root/appimages/$filename"

        if appimage_exists "$filepath"; then
            log_success "$name: OK"
        else
            log_error "$name: MISSING or not executable"
            all_present=false
        fi
    done

    return $([ "$all_present" = true ] && echo 0 || echo 1)
}

# Main download function
download_appimages() {
    local project_root
    project_root="$(get_project_root)"
    local failed=0

    log_info "Downloading AppImages to $project_root/appimages/"
    echo ""

    # Ensure appimages directory exists
    ensure_directory "$project_root/appimages"

    # Download each AppImage
    for name in "${DOWNLOAD_ORDER[@]}"; do
        if ! download_appimage "$name"; then
            ((failed++))
        fi
        echo ""
    done

    # Create versions manifest
    create_versions_manifest

    # Final verification
    echo ""
    if verify_appimages; then
        log_success "All AppImages downloaded successfully"
        return 0
    else
        log_error "$failed AppImage(s) failed to download"
        log_info "You can re-run this script to retry failed downloads"
        return 1
    fi
}

# Run if executed directly (not sourced)
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    download_appimages
    exit $?
fi

# Run when sourced from install.sh
download_appimages
