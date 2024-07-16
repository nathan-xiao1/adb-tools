#!/bin/bash

source modules/common/adb-utils.sh
source modules/common/ansi-escape-codes.sh
source modules/common/message-helpers.sh

usage() {
    echo "Usage: $0 {install|screenshot}"
    exit 1
}

# Check if the number of arguments is non-zero
if [ $# -eq 0 ]; then
    usage
fi

# Parse the first argument and call the corresponding function
case $1 in
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
