#!/bin/bash
#
# Retro Station - BIOS Download Helper
#

# Requires: log_info, log_warning, log_error from common.sh

load_bios_files() {
    log_info "Starting BIOS download routine..."
    command -v wget >/dev/null 2>&1 || {
        log_error "wget not installed. Cannot download BIOS files."
        return 1
    }

    local ROOT="$PROJECT_ROOT/bios"

    # Helper: download a file only if missing
    fetch_bios() {
        local url="$1"
        local outdir="$2"
        local outfile="$3"

        mkdir -p "$outdir"

        if [ -f "$outdir/$outfile" ]; then
            log_info "Already present: $outfile"
            return 0
        fi

        log_info "Downloading: $outfile"
        if wget -q -O "$outdir/$outfile" "$url"; then
            log_success "Downloaded: $outfile"
        else
            log_warning "Failed to download: $outfile"
        fi
    }

    #
    # PlayStation 1
    #
    fetch_bios "https://archive.org/download/the-ultimate-playstation-1-bios/scph5500.bin" \
               "$ROOT/psx" "scph5500.bin"

    fetch_bios "https://archive.org/download/the-ultimate-playstation-1-bios/scph5501.bin" \
               "$ROOT/psx" "scph5501.bin"

    fetch_bios "https://archive.org/download/the-ultimate-playstation-1-bios/scph5502.bin" \
               "$ROOT/psx" "scph5502.bin"

    #
    # PlayStation 2
    #
    fetch_bios "https://archive.org/download/the-ultimate-ps2-bios-collection/SCPH-70012_BIOS_V12_USA_200.BIN" \
               "$ROOT/ps2" "SCPH-70012_BIOS_V12_USA_200.BIN"

    #
    # Nintendo DS
    #
    fetch_bios "https://archive.org/download/nds-bios-firmware/bios7.bin" \
               "$ROOT/nds" "bios7.bin"

    fetch_bios "https://archive.org/download/nds-bios-firmware/bios9.bin" \
               "$ROOT/nds" "bios9.bin"

    fetch_bios "https://archive.org/download/nds-bios-firmware/firmware.bin" \
               "$ROOT/nds" "firmware.bin"

    #
    # Game Boy Advance / Game Boy Color
    #
    fetch_bios "https://archive.org/download/gba_bios_202501/gba_bios.zip/gba_bios.bin" \
               "$ROOT/gba" "gba_bios.bin"

    fetch_bios "https://archive.org/download/gbc_bios/gbc_bios.zip/gbc_bios.bin" \
               "$ROOT/gba" "gbc_bios.bin"

    log_info "BIOS download routine completed."
}
