#!/bin/bash

_wireless_connect() {
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

    local filtered_devices=()
    for device in "${devices[@]}"; do
        if [[ "$device" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+:[0-9]+$ ]]; then
            echo -e "${FG_DIM}Skipping $device...${RESET}"
        else
            filtered_devices+=("$device")
        fi
    done

    devices=(${filtered_devices[*]})

    echo -e "Devices: ${FG_CYAN}${devices[*]}${RESET}"
    echo -e ""

    # Check that each specified device is connected
    if [ "$did_specify_devices" == "true" ]; then
        for device in "${devices[@]}"; do
            if [[ ! " ${adb_devices[*]} " =~ " ${device} " ]]; then
                error_msg "device '${device}' not found"
                return 1
            fi
        done
    fi

    # Set each target device to listen for a TCP/IP connection on port 5555
    local port=5555
    for device in "${devices[@]}"; do
        adb -s "${device}" tcpip "${port}" >/dev/null 2>&1
    done

    # Wait for the adb daemon on the device to be restarted
    sleep 3

    for device in "${devices[@]}"; do
        local ip
        ip=$(adb -s "${device}" shell "ip -f inet addr show wlan0 | awk '/inet / {print \$2}' | cut -d/ -f1")

        adb connect "${ip}:${port}" >/dev/null 2>&1

        device_printf "$device" "Conncted to ${ip}:${port}"
    done

}

adb_tools_module_main_cli() {
    _wireless_connect "$@"
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
        _wireless_connect
    else
        _wireless_connect "$selected_device"
    fi
}
