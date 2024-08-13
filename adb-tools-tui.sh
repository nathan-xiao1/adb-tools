#!/bin/bash

source modules/common/ansi-escape-codes.sh
source modules/common/select-option.sh

echo -ne "${FG_MAGENTA}"
echo -e '
                $$\ $$\               $$\                         $$\           
                $$ |$$ |              $$ |                        $$ |          
 $$$$$$\   $$$$$$$ |$$$$$$$\        $$$$$$\    $$$$$$\   $$$$$$\  $$ | $$$$$$$\ 
 \____$$\ $$  __$$ |$$  __$$\       \_$$  _|  $$  __$$\ $$  __$$\ $$ |$$  _____|
 $$$$$$$ |$$ /  $$ |$$ |  $$ |        $$ |    $$ /  $$ |$$ /  $$ |$$ |\$$$$$$\  
$$  __$$ |$$ |  $$ |$$ |  $$ |        $$ |$$\ $$ |  $$ |$$ |  $$ |$$ | \____$$\ 
\$$$$$$$ |\$$$$$$$ |$$$$$$$  |        \$$$$  |\$$$$$$  |\$$$$$$  |$$ |$$$$$$$  |
 \_______| \_______|\_______/          \____/  \______/  \______/ \__|\_______/
'
echo -e "${RESET}"

echo -e "Select an action: ${FG_DIM}(Enter 'q' or Ctrl+C to quit)${RESET}"
echo -e ""

# Modules definitions. Syntax: "{description} | {module path}"
modules=(
    "List connected ADB devices | modules/devices.sh"
    "Install APK to device | modules/install-apk.sh"
    "Take screenshot of device | modules/screenshot.sh"
    "Display and control device (scrcpy) | modules/scrcpy.sh"
    "Connect wirelessly with a device after an initial USB connection | modules/wireless-connect.sh"
)

# Print each module with a selection number
number=1
for module in "${modules[@]}"; do
    # Split the string and get the description
    IFS='|' read -r -a parts <<<"$module"
    description=$(echo "${parts[0]}" | sed 's/^[[:space:]]*//; s/[[:space:]]*$//')

    echo -e " ${FG_BOLD_BLUE}$number.${RESET} $description"
    number=$((number + 1))
done

echo -e ""

# Read user input to get a valid selection
while true; do
    echo -ne "${FG_BOLD_WHITE}Enter selection: ${RESET}"
    read -r input
    if [[ "$input" == "q" ]]; then
        exit 0
    elif [[ "$input" =~ ^[0-9]+$ && "$input" -gt 0 && "$input" -le ${#modules[@]} ]]; then
        break
    else
        echo -e "${FG_RED}Please enter a valid selection${RESET}"
        echo -e ""
    fi
done

# Get the module path of the selected module
selected_module=${modules[$((input - 1))]}
IFS='|' read -r -a parts <<<"$selected_module"
description=$(echo "${parts[0]}" | sed 's/^[[:space:]]*//; s/[[:space:]]*$//')
module_path=$(echo "${parts[1]}" | sed 's/^[[:space:]]*//; s/[[:space:]]*$//')

echo -e "Selected: ${FG_BOLD_BLUE}$description${RESET}"

echo -e ""

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
source "$script_dir/$module_path"

adb_tools_module_main_tui "$@"
