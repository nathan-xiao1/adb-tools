#!/bin/bash

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"

source "$script_dir/modules/common/adb-utils.sh"
source "$script_dir/modules/common/ansi-escape-codes.sh"
source "$script_dir/modules/common/message-helpers.sh"

# Use the interactive text user interface (TUI) if no argument is specified,
# otherwise use the CLI interface.
if [[ $# -eq 0 ]]; then
    source "$script_dir/adb-tools-tui.sh"
else
    # Parse the first argument and call the corresponding function
    case $1 in
    devices)
        module_path="modules/devices.sh"
        shift
        ;;
    install)
        module_path="modules/install-apk.sh"
        shift
        ;;
    screenshot)
        module_path="modules/screenshot.sh"
        shift
        ;;
    *)
        echo -e "${FG_RED}Unknown command '$1'${RESET}"
        exit 1
        ;;
    esac

    (source "$script_dir/$module_path" && adb_tools_module_main_cli "$@")
fi
