#!/bin/bash

_device_info() {
    # Default values
    local devices=()

    # Get the list of connected devices
    local adb_devices=($(_get_adb_devices))
    if [[ -z "${adb_devices[*]}" ]]; then
        error_msg "No devices found."
        return 1
    fi

    # Did specify devices as command arguments
    local did_specify_devices
    did_specify_devices=$([ $# -ne 0 ] && echo "true" || echo "false")

    # Defaults to all connected devices if no device is specified
    if [ "$did_specify_devices" == "false" ]; then
        devices=("${adb_devices[@]}")
    else
        devices=("$@")
    fi

    echo -e "Devices: ${FG_CYAN}${devices[*]}${RESET}"

    # Check that each specified device is connected
    if [ "$did_specify_devices" == "true" ]; then
        for device in "${devices[@]}"; do
            if [[ ! " ${adb_devices[*]} " =~ " ${device} " ]]; then
                error_msg "device '${device}' not found"
                return 1
            fi
        done
    fi

    echo ""

    # Iterate through each device to get the device info
    for device in "${devices[@]}"; do
        # Run in parallel in subshells
        device_prop=$(adb -s "$device" shell getprop)

        echo -e "${FG_BOLD_CYAN}$device${RESET}"
        echo -e " > Brand:       ${FG_BOLD_WHITE}$(_get_value_from_prop "$device_prop" "ro.product.brand")${RESET}"
        echo -e " > Model:       ${FG_BOLD_WHITE}$(_get_value_from_prop "$device_prop" "ro.product.model")${RESET}"
        echo -e " > Version:     ${FG_BOLD_WHITE}$(_get_value_from_prop "$device_prop" "ro.build.version.release")${RESET}"
        echo -e " > API Version: ${FG_BOLD_WHITE}$(_get_value_from_prop "$device_prop" "ro.build.version.sdk")${RESET}"

        echo ""
    done
}

_get_value_from_prop() {
    device_prop=$1
    prop=$2
    echo "$device_prop" | grep "\[$prop\]:" | awk -F'[][]' '{print $4}'
}

adb_tools_module_main_cli() {
    _device_info "$@"
}

adb_tools_module_main_tui() {
    # Get list of devices to select from
    local adb_devices=("All devices")
    adb_devices+=($(_get_adb_devices))

    # Get user selection
    select_option "Select a device to display and control" "${adb_devices[@]}"
    local selected_device_index=$?
    local selected_device="${adb_devices[selected_device_index]}"

    echo -e "${FG_BOLD_WHITE}Selected device${RESET}: ${selected_device}"

    # Index 0 is "All devices"
    if [[ $selected_device_index == 0 ]]; then
        selected_device=""
    fi

    _device_info "$selected_device"
}
