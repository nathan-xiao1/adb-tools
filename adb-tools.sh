#!/bin/bash

source modules/common/adb-utils.sh
source modules/common/ansi-escape-codes.sh
source modules/common/message-helpers.sh

# Check if the number of arguments is non-zero
if [ $# -eq 0 ]; then
    echo "Usage: $0 {install}"
    exit 1
fi

# Parse the first argument and call the corresponding function
case $1 in
install)
    shift
    echo -e
    (modules/install-apk.sh "$@")
    ;;
*)
    echo "Usage: $0 {install}"
    exit 1
    ;;
esac
