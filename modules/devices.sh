#!/bin/bash

adb_devices=($(_get_adb_devices))

if [[ -z "${adb_devices[*]}" ]]; then
    echo -e "${FG_YELLOW}No devices connected.${RESET}"
else
    echo -e "${FG_BOLD_MAGENTA}Connected ADB devices:${RESET}"
    for device in "${adb_devices[@]}"; do
        echo -e " ${FG_BLUE}>${RESET} $device"
    done
fi
