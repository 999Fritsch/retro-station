#!/bin/bash
#
# Retro Station - Phase 5: BIOS Verification
# Checks for required BIOS files and verifies checksums
#

# Source common helper functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

# Status symbols
SYMBOL_OK="✓"
SYMBOL_MISSING="✗"
SYMBOL_WARNING="⚠"

# Counters
TOTAL_CHECKED=0
TOTAL_FOUND=0
TOTAL_MISSING=0
TOTAL_WRONG_CHECKSUM=0

# BIOS definitions: path|md5|required|description
# Format: relative_path|expected_md5|required(yes/no)|description
declare -a BIOS_FILES=(
    # PlayStation 1 - at least one required
    "psx/scph5500.bin|8dd7d5296a650fac7319bce665a6a53c|optional|PS1 BIOS (Japan)"
    "psx/scph5501.bin|490f666e1afb15b7362b406ed1cea246|optional|PS1 BIOS (USA)"
    "psx/scph5502.bin|32736f17079d0b2b7024407c39bd3050|optional|PS1 BIOS (Europe)"

    # PlayStation 2 - at least one required
    "ps2/SCPH-70012_BIOS_V12_USA_200.BIN|d333558cc14561c1fdc334c75d5f37b7|optional|PS2 BIOS v2.00 (USA)"
    "ps2/SCPH-39001_BIOS_V7_USA_160.BIN|d5ce2c7d119f563ce04bc04571de2571|optional|PS2 BIOS v1.60 (USA)"

    # Nintendo DS - all required
    "nds/bios7.bin|df692a80a5b1bc90571b14d864c738de|yes|NDS ARM7 BIOS"
    "nds/bios9.bin|a392174eb3e572fed6447e956bde4b25|yes|NDS ARM9 BIOS"
    "nds/firmware.bin|any|yes|NDS Firmware"

    # Game Boy Advance - optional
    "gba/gba_bios.bin|a860e8c0b6d573d191e4ec7db1b1e4f6|optional|GBA BIOS"
)

# Check if md5sum is available
check_md5_tool() {
    if command -v md5sum &>/dev/null; then
        echo "md5sum"
    elif command -v md5 &>/dev/null; then
        echo "md5"
    else
        log_error "No MD5 tool found (md5sum or md5)"
        return 1
    fi
}

# Calculate MD5 checksum of a file
get_md5() {
    local file="$1"
    local md5_tool
    md5_tool=$(check_md5_tool)

    if [ "$md5_tool" = "md5sum" ]; then
        md5sum "$file" 2>/dev/null | cut -d' ' -f1
    else
        md5 -q "$file" 2>/dev/null
    fi
}

# Verify a single BIOS file
verify_bios_file() {
    local bios_def="$1"
    local project_root
    project_root="$(get_project_root)"

    # Parse definition
    local rel_path="${bios_def%%|*}"
    local remainder="${bios_def#*|}"
    local expected_md5="${remainder%%|*}"
    remainder="${remainder#*|}"
    local required="${remainder%%|*}"
    local description="${remainder#*|}"

    local full_path="$project_root/bios/$rel_path"

    TOTAL_CHECKED=$((TOTAL_CHECKED + 1))

    # Check if file exists
    if [ ! -f "$full_path" ]; then
        if [ "$required" = "yes" ]; then
            echo -e "  ${COLOR_RED}${SYMBOL_MISSING}${COLOR_RESET} $rel_path - ${COLOR_RED}MISSING${COLOR_RESET} ($description)"
            TOTAL_MISSING=$((TOTAL_MISSING + 1))
            return 1
        else
            echo -e "  ${COLOR_YELLOW}${SYMBOL_MISSING}${COLOR_RESET} $rel_path - not found ($description) [optional]"
            return 0
        fi
    fi

    # File exists - verify checksum if not "any"
    if [ "$expected_md5" = "any" ]; then
        echo -e "  ${COLOR_GREEN}${SYMBOL_OK}${COLOR_RESET} $rel_path - ${COLOR_GREEN}FOUND${COLOR_RESET} ($description)"
        TOTAL_FOUND=$((TOTAL_FOUND + 1))
        return 0
    fi

    local actual_md5
    actual_md5=$(get_md5 "$full_path")

    if [ "$actual_md5" = "$expected_md5" ]; then
        echo -e "  ${COLOR_GREEN}${SYMBOL_OK}${COLOR_RESET} $rel_path - ${COLOR_GREEN}FOUND${COLOR_RESET} ($description)"
        TOTAL_FOUND=$((TOTAL_FOUND + 1))
        return 0
    else
        echo -e "  ${COLOR_YELLOW}${SYMBOL_WARNING}${COLOR_RESET} $rel_path - ${COLOR_YELLOW}CHECKSUM MISMATCH${COLOR_RESET} ($description)"
        echo -e "      Expected: $expected_md5"
        echo -e "      Got:      $actual_md5"
        TOTAL_WRONG_CHECKSUM=$((TOTAL_WRONG_CHECKSUM + 1))
        TOTAL_FOUND=$((TOTAL_FOUND + 1))
        return 0
    fi
}

# Check if at least one PS1 BIOS is present
check_psx_bios() {
    local project_root
    project_root="$(get_project_root)"
    local found=false

    for bios in scph5500.bin scph5501.bin scph5502.bin scph1001.bin scph7001.bin scph7502.bin; do
        if [ -f "$project_root/bios/psx/$bios" ]; then
            found=true
            break
        fi
    done

    echo "$found"
}

# Check if at least one PS2 BIOS is present
check_ps2_bios() {
    local project_root
    project_root="$(get_project_root)"

    # Check for any .BIN or .bin file in ps2 directory
    if ls "$project_root/bios/ps2/"*.BIN 2>/dev/null | head -1 | grep -q .; then
        echo "true"
        return
    fi
    if ls "$project_root/bios/ps2/"*.bin 2>/dev/null | head -1 | grep -q .; then
        echo "true"
        return
    fi

    echo "false"
}

# Print system status summary
print_system_summary() {
    local system="$1"
    local status="$2"
    local note="$3"

    if [ "$status" = "ok" ]; then
        echo -e "${COLOR_GREEN}${SYMBOL_OK}${COLOR_RESET} $system: Ready"
    elif [ "$status" = "optional" ]; then
        echo -e "${COLOR_YELLOW}${SYMBOL_WARNING}${COLOR_RESET} $system: $note"
    else
        echo -e "${COLOR_RED}${SYMBOL_MISSING}${COLOR_RESET} $system: $note"
    fi
}

# Main verification function
verify_bios() {
    local project_root
    project_root="$(get_project_root)"

    echo ""
    echo "╔════════════════════════════════════════════════════════════════╗"
    echo "║                    BIOS Verification Report                    ║"
    echo "╚════════════════════════════════════════════════════════════════╝"
    echo ""
    echo "BIOS Directory: $project_root/bios/"
    echo ""

    # Check each BIOS file
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "Individual File Status:"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""

    for bios_def in "${BIOS_FILES[@]}"; do
        verify_bios_file "$bios_def" || true
    done

    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "System Readiness:"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""

    # PlayStation 1
    if [ "$(check_psx_bios)" = "true" ]; then
        print_system_summary "PlayStation 1" "ok"
    else
        print_system_summary "PlayStation 1" "missing" "No BIOS found - games won't run"
    fi

    # PlayStation 2
    if [ "$(check_ps2_bios)" = "true" ]; then
        print_system_summary "PlayStation 2" "ok"
    else
        print_system_summary "PlayStation 2" "missing" "No BIOS found - games won't run"
    fi

    # Nintendo DS
    local nds_ready=true
    [ ! -f "$project_root/bios/nds/bios7.bin" ] && nds_ready=false
    [ ! -f "$project_root/bios/nds/bios9.bin" ] && nds_ready=false
    [ ! -f "$project_root/bios/nds/firmware.bin" ] && nds_ready=false

    if [ "$nds_ready" = "true" ]; then
        print_system_summary "Nintendo DS" "ok"
    else
        print_system_summary "Nintendo DS" "missing" "Missing required files"
    fi

    # Game Boy Advance
    if [ -f "$project_root/bios/gba/gba_bios.bin" ]; then
        print_system_summary "Game Boy Advance" "ok"
    else
        print_system_summary "Game Boy Advance" "optional" "BIOS not found (optional - HLE available)"
    fi

    # Systems without BIOS requirements
    print_system_summary "GameCube" "ok"
    print_system_summary "Wii" "ok"
    print_system_summary "NES" "ok"
    print_system_summary "SNES" "ok"
    print_system_summary "Genesis" "ok"
    print_system_summary "Nintendo 64" "ok"

    # Summary
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "Summary:"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "  Files checked:        $TOTAL_CHECKED"
    echo "  Files found:          $TOTAL_FOUND"
    echo "  Files missing:        $TOTAL_MISSING"
    echo "  Checksum mismatches:  $TOTAL_WRONG_CHECKSUM"
    echo ""

    if [ $TOTAL_MISSING -gt 0 ]; then
        log_warning "Some BIOS files are missing."
        echo ""
        log_info "See docs/BIOS_CHECKLIST.md for:"
        echo "  - Required files and checksums"
        echo "  - Where to place each file"
        echo "  - How to dump BIOS from your hardware"
        echo ""
        return 1
    elif [ $TOTAL_WRONG_CHECKSUM -gt 0 ]; then
        log_warning "Some BIOS files have unexpected checksums."
        echo "  This may be okay if they are valid alternate versions."
        echo ""
        return 0
    else
        log_success "All checked BIOS files are present and valid!"
        echo ""
        return 0
    fi
}

# Run if executed directly (not sourced)
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    verify_bios
    exit $?
fi

# Run when sourced from install.sh
verify_bios
