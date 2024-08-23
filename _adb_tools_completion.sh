#!/bin/bash

# Returns a list of connected ADB devices that hasn't been used already in the current
# command
function _adb_devices_completion_list_unique() {
    local adb_devices=($(adb devices | awk '/device$/{print $1}'))

    # Exclude devices that have already been used as arguments by
    # checking words in the command excluding the first word (the function call)
    local available_devices=("${adb_devices[@]}")
    local unique_devices=()

    for device in "${available_devices[@]}"; do
        # Only suggest if the option is not already in the command
        if ! [[ " ${COMP_WORDS[*]} " =~ " ${device} " ]]; then
            unique_devices+=("$device")
        fi
    done

    echo "${unique_devices[@]}"
}

_adb_tools_completion() {
    local cur prev opts_main

    COMPREPLY=()
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD - 1]}"

    opts_main="devices install screenshot scrcpy wireless-connect"

    # Handle main commands
    if [[ ${COMP_CWORD} -eq 1 ]]; then
        COMPREPLY=($(compgen -W "${opts_main}" -- ${cur}))
        return 0
    fi

    # Handle subcommands
    subcommand="${COMP_WORDS[1]}"
    case ${subcommand} in

    install)
        if [[ ${cur} == -* ]]; then
            # Suggest flag if "-" is matched
            local opts_flags="--apk"
            COMPREPLY=($(compgen -W "${opts_flags}" -- ${cur}))
        elif [[ ${prev} == "--apk" ]]; then
            # Suggest files if "--apk" is the previous argument
            COMPREPLY=($(compgen -f -- ${cur}))
        else
            # Suggest ADB devices otherwise
            COMPREPLY=($(compgen -C _adb_devices_completion_list_unique -- ${cur}))
        fi
        ;;

    screenshot)
        if [[ ${cur} == -* ]]; then
            # Suggest flag if "-" is matched
            local opts_flags="-d --dir -n --no-open"
            COMPREPLY=($(compgen -W "${opts_flags}" -- ${cur}))
        elif [[ ${prev} == "-d" ]] || [[ ${prev} == "-dir" ]]; then
            # Suggest files if "-d" or "--dir" is thze previous argument
            COMPREPLY=($(compgen -f -- ${cur}))
        else
            # Suggest ADB devices otherwise
            COMPREPLY=($(compgen -C _adb_devices_completion_list_unique -- ${cur}))
        fi
        ;;

    scrcpy)
        # Suggest ADB devices
        COMPREPLY=($(compgen -C _adb_devices_completion_list_unique -- ${cur}))
        ;;

    wireless-connect)
        # Suggest ADB devices
        COMPREPLY=($(compgen -C _adb_devices_completion_list_unique -- ${cur}))
        ;;

    *)
        COMPREPLY=()
        ;;
    esac

    return 0
}

complete -F _adb_tools_completion adb-tools
complete -F _adb_tools_completion adb-tools.sh
