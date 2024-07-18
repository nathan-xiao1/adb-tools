#!/bin/bash

adb_devices() {
    local adb_devices=($(_get_adb_devices))

    if [[ -z "${adb_devices[*]}" ]]; then
        echo -e "${FG_YELLOW}No devices connected.${RESET}"
    else
        echo -e "${FG_BOLD_MAGENTA}Connected ADB devices:${RESET}"
        for device in "${adb_devices[@]}"; do
            echo -e " ${FG_BLUE}>${RESET} $device"
        done
    fi
}

adb_tools_module_main_cli() {
    adb_devices
}

adb_tools_module_main_tui() {
    adb_devices
}
