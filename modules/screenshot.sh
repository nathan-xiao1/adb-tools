#!/bin/bash

# Default values
timestamp=$(date +%Y%m%d-%I.%M.%S%p)
save_dir="${HOME}/Pictures/ADB Screenshots"
devices=()
open_screenshot=true

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
    -d | --dir)
        save_dir="$2"
        shift 2
        ;;
    -n | --no-open)
        open_screenshot=false
        shift 1
        ;;
    -*)
        echo "Unknown option $1"
        exit 1
        ;;
    *)
        devices+=("$1")
        shift
        ;;
    esac
done

# Get the list of connected devices
adb_devices=($(_get_adb_devices))
if [[ -z "${adb_devices[*]}" ]]; then
    error_msg "No devices found."
    exit 1
fi

# Did specify devices as command arguments
did_specify_devices=$([ ${#devices[@]} -ne 0 ] && echo "true" || echo "false")

# Defaults to all connected devices if no device is specified
if [ "$did_specify_devices" == "false" ]; then
    devices=("${adb_devices[@]}")
fi

echo -e "Devices: ${FG_CYAN}${devices[*]}${RESET}"

# Check that each specified device is connected
for device in "${devices[@]}"; do
    if [[ ! " ${adb_devices[*]} " =~ " ${device} " ]]; then
        error_msg "device '${device}' not found"
        exit 1
    fi
done

echo -e "Screenshot Directory: ${FG_CYAN}${save_dir}${RESET}\n"
screenshots=()

# Iterate through each device to take a screenshot of
for device in "${devices[@]}"; do
    filename="${save_dir}/${timestamp}-${device}.png"
    echo -e "Capturing screenshot on ${FG_MAGENTA}${device}${RESET}..."

    # Check whether the adb screenshot command succeeded
    if adb -s "$device" exec-out screencap -p >"$filename"; then
        echo -e "${FG_GREEN} > Screenshot saved as ${FG_BOLD_GREEN}${filename}${RESET}\n"
    else
        echo -e "${FG_RED} > Failed to screenshot on ${device}${RESET}\n"
    fi

    screenshots+=("$filename")
done

if [[ $open_screenshot == true && -n "${screenshots[*]}" ]]; then
    echo -e "Opening captured screenshots..."
    for screenshot in "${screenshots[@]}"; do
        open "$screenshot"
    done
fi
