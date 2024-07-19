#!/bin/bash

_adb_screenshot() {
    # Default values
    local timestamp=$(date +%Y%m%d-%I.%M.%S%p)
    local save_dir="${HOME}/Pictures/ADB Screenshots"
    local devices=()
    local open_screenshot=true

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
    local adb_devices=($(_get_adb_devices))
    if [[ -z "${adb_devices[*]}" ]]; then
        error_msg "No devices found."
        exit 1
    fi

    # Did specify devices as command arguments
    local did_specify_devices
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
    local screenshots=()

    # Iterate through each device to take a screenshot of
    for device in "${devices[@]}"; do
        local filename="${save_dir}/${timestamp}-${device}.png"
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
}

adb_tools_module_main_cli() {
    _adb_screenshot "$@"
}

adb_tools_module_main_tui() {
    # Get list of devices to select from
    local adb_devices=("All devices")
    adb_devices+=($(_get_adb_devices))

    # Get user selection
    select_option "Select a device to screenshot" "${adb_devices[@]}"
    local selected_device_index=$?
    local selected_device

    # Index 0 is "All devices"
    if [[ $selected_device_index == 0 ]]; then
        selected_device=""
    else
        selected_device="${adb_devices[selected_device_index]}"
    fi

    # Get user selection
    local open_screenshot_options=("Yes" "No")
    select_option "Open the screenshot after it has been taken?" "${open_screenshot_options[@]}"
    local open_screenshot_options_index=$?
    local open_screenshot_option="${open_screenshot_options[open_screenshot_options_index]}"

    if [[ "$open_screenshot_option" == "Yes" ]]; then
        open_screenshot_option=""
    else
        open_screenshot_option="--no-open"
    fi

    _adb_screenshot "$selected_device" "$open_screenshot_option"
}
