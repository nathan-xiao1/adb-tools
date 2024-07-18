#!/bin/bash

# Installs an APK file to connected ADB devices
_install_apk() {

    # Default values
    local apk_path="app/test.apk"
    local devices=()

    # Parse command line arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
        -a | --apk)
            apk_path="$2"
            shift 2
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
        return 1
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
    if [ "$did_specify_devices" == "true" ]; then
        for device in "${devices[@]}"; do
            if [[ ! " ${adb_devices[*]} " =~ " ${device} " ]]; then
                error_msg "device '${device}' not found"
                return 1
            fi
        done
    fi

    # Check if the APK file exists
    echo -e "APK File: ${FG_CYAN}${apk_path}${RESET}\n"
    if [[ ! -f "$apk_path" ]]; then
        error_msg "${apk_path} does not exist or is not a valid file."
        return 1
    fi

    # Track all the parallel background jobs
    pids=()

    # Setup trap to catch Ctrl+C (SIGINT) to kill all child processes
    trap 'echo -e "\n${FG_YELLOW}Cancelling child jobs...${RESET}" >&2 && kill 0' INT

    # Iterate through each device to install on and install the apk
    for device in "${devices[@]}"; do
        # Run in parallel in subshells
        (
            device_printf "$device" "Installing and launching APK on ${FG_MAGENTA}$device${RESET}..."

            # Install and launch the apk
            if _install_apk_single "$device" "$apk_path"; then
                if _launch_apk "$device" "$apk_path"; then
                    device_printf "$device" "${FG_GREEN}Successfully installed and launched on $device${RESET}"
                else
                    device_printf "$device" "${FG_RED}Failed to launch package on $device${RESET}"
                    return 2
                fi
            else
                device_printf "$device" "${FG_RED}Failed to install on ${device}${RESET}"
                return 1
            fi
        ) &

        # Record the PID of each subshell
        pids+=($!)
    done

    # Flag to track the overall success of installations
    local installSuccess=true
    local launchSuccess=true

    # Wait for all background jobs to finish and collect their exit statuses
    for pid in "${pids[@]}"; do
        wait "$pid"
        exit_code=$?
        if [[ $exit_code == 1 ]]; then
            installSuccess=false
        elif [[ $exit_code == 2 ]]; then
            launchSuccess=false
        fi
    done

    # Newline for cleaner output
    echo ""

    # Check the overall success
    if [[ $installSuccess == true ]] && [[ $launchSuccess == true ]]; then
        success_msg "APK installed and launched"
    else
        if [[ $installSuccess == false ]]; then
            warning_msg "One or more installations failed"
        fi
        if [[ $launchSuccess == false ]]; then
            warning_msg "One or more launch failed"
        fi
    fi
}

_install_apk_single() {
    local device=$1
    local apk_path=$2

    local output
    output=$(adb -s "$device" install -d -r "$apk_path" 2>&1 >/dev/null)
    local adb_install_exit_code=$?

    # Check the exit code of the adb install command
    if [[ $adb_install_exit_code -ne 0 ]]; then
        # Extract the error message
        local error
        error=$(echo $output | sed 's/[^:]*:[^:]*:[[:blank:]]*//')
        if [[ -n "$error" ]]; then
            device_printf "$device" "${FG_RED}${error}${RESET}"
        fi
        return 1
    fi
}

_launch_apk() {
    local device=$1
    local apk_path="${2:-app/build/outputs/apk/tiktokI18n/debug/app-tiktok-i18n-debug.apk}"
    local packageName=$(_aapt_dump "$apk_path" 'package')
    local launchActivity=$(_get_launcher_activity "$apk_path")

    if [ -n "$packageName" ] && [ -n "$launchActivity" ]; then
        if [ -n "$device" ]; then
            adb -s "$device" shell am start -n "$packageName/$launchActivity" >/dev/null
        else
            adb shell am start -n "$packageName/$launchActivity" >/dev/null
        fi
    fi

    # Check the exit code of the adb install command
    if [[ $? -ne 0 ]]; then
        return 1
    fi
}

adb_tools_module_main_cli() {
    # Wrapper for _install_apk which removes the job control message for
    # the parallel jobs.
    _install_apk "$@" | sed -E '/^\[[0-9]+\][[:space:]]+(-)?[[:space:]]*[0-9]+/d'
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

    # Get the path to the APK file
    echo -ne "${FG_BOLD_WHITE}APK Path: ${RESET}"
    read -er apk_path

    echo -e ""

    _install_apk "$selected_device" --apk "$apk_path" | sed -E '/^\[[0-9]+\][[:space:]]+(-)?[[:space:]]*[0-9]+/d'
}
