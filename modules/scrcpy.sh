#!/bin/bash

_scrcpy() {
    # Default values
    local devices=()

    # Check if scrcpy is installed
    if ! scrcpy -v >/dev/null 2>&1; then
        echo "${FG_RED}ERROR: scrcpy is not installed. Install it from here: https://github.com/Genymobile/scrcpy${RESET}"
        return 1
    fi

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

    # Setup trap to catch Ctrl+C (SIGINT) to kill all child processes
    trap 'echo -e "\n${FG_YELLOW}Cancelling child jobs...${RESET}" >&2 && kill 0' INT

    # Iterate through each device to install on and install the apk
    for device in "${devices[@]}"; do
        # Run in parallel in subshells
        scrcpy -s "${device}" &

        # Record the PID of each subshell
        pids+=($!)
    done

    # Wait for all background jobs to finish and collect their exit statuses
    wait

    echo -e "${FG_GREEN}Done${RESET}"
}

adb_tools_module_main_cli() {
    _scrcpy "$@"
}

adb_tools_module_main_tui() {
    # Get list of devices to select from
    local adb_devices=("All devices")
    adb_devices+=($(_get_adb_devices))

    # Get user selection
    select_option "${adb_devices[@]}"
    local selected_device_index=$?
    local selected_device="${adb_devices[selected_device_index]}"

    echo -e "${FG_BOLD_WHITE}Selected device${RESET}: ${selected_device}"

    # Index 0 is "All devices"
    if [[ $selected_device_index == 0 ]]; then
        selected_device=""
    fi

    _scrcpy "$selected_device"
}
