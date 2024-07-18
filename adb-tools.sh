#!/bin/bash

source modules/common/adb-utils.sh
source modules/common/ansi-escape-codes.sh
source modules/common/message-helpers.sh

usage() {
    echo "Usage: $0 {install|screenshot}"
    exit 1
}

# Use the interactive interface if no argument is specified,
# otherwise use the CLI interface.
if [ $# -eq 0 ]; then
    source modules/main.sh
else
    # Parse the first argument and call the corresponding function
    case $1 in
    devices)
        shift
        (modules/devices.sh "$@")
        ;;
    install)
        shift
        (modules/install-apk.sh "$@")
        ;;
    screenshot)
        shift
        (modules/screenshot.sh "$@")
        ;;
    *)
        usage
        ;;
    esac

fi
