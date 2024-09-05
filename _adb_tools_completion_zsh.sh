#!/bin/zsh

# Returns a list of connected ADB devices that hasn't been used already in the current
# command
function _adb_devices_completion_list_unique() {
    local no_wireless=false
    if [[ "$1" == "--no-wireless" ]]; then
        no_wireless=true
    fi

    local adb_devices=($(adb devices | awk '/device$/{print $1}'))

    # Exclude devices that have already been used as arguments by
    # checking words in the command excluding the first word (the function call)
    local available_devices=("${adb_devices[@]}")
    local unique_devices=()

    for device in "${available_devices[@]}"; do
        # Check if wireless device
        if $no_wireless && [[ "$device" == *":"* ]]; then
            continue
        fi

        # Only suggest if the option is not already in the command
        if ! [[ " ${words[*]} " =~ " ${device} " ]]; then
            unique_devices+=("$device")
        fi
    done

    echo "${unique_devices[@]}"
}

_adb_tools_completion() {
    local line state state_descr contexts ret=1

    # Main options
    local -a main_opts=(
        'devices:List connected devices'
        'install:Install an APK file to a device'
        'screenshot:Take a screenshot on a device'
        'scrcpy:Show the device screen on your computer'
        'wireless-connect:Setup a wired device for wireless ADB'
    )

    # Subcommands options
    local -A subcommands
    subcommands=(
        'install:--apk:Specify the APK file path:_files'
        'screenshot:-d[Specify directory] --dir[Specify directory] -n[No open after screenshot] --no-open[No open after screenshot]:directory:_files'
    )

    _arguments \
        '1:command:->command' \
        '*:argument:->args'

    case "$state" in
    command)
        _describe -t commands 'adb-tools commands' main_opts
        ;;
    args)
        local available_devices=($(_adb_devices_completion_list_unique))

        case "$words[2]" in
        install)
            _arguments \
                '*:Connected ADB devices:compadd -a available_devices' \
                '-a[APK path]:APK file:_files' \
                '--apk[APK path]:APK file:_files' &&
                ret=0
            ;;
        screenshot)
            _arguments \
                '*:Connected ADB devices:compadd -a available_devices' \
                '-d[Directory to store the screenshots]:Directory:_directories' \
                '--dir[Directory to store the screenshots]:Directory:_directories' \
                '-n[Don'\''t open screenshots]' \
                '--no-open[Don'\''t open screenshots]' &&
                ret=0
            ;;
        scrcpy)
            _arguments \
                '*:Connected ADB devices:compadd -a available_devices' &&
                ret=0
            ;;
        wireless-connect)
            available_devices=($(_adb_devices_completion_list_unique --no-wireless))
            _arguments \
                '*:Connected ADB devices:compadd -a available_devices' &&
                ret=0
            ;;
        *) ;;
        esac
        ;;
    *) ;;
    esac
    return ret
}

# Register the completion function for the command
compdef _adb_tools_completion adb-tools adb-tools.sh
