#!/bin/bash

source modules/common/ansi-escape-codes.sh

echo -e "${FG_MAGENTA}"
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

echo -e ""
echo -e "Select an action:"
echo -e ""

# Modules definitions. Syntax: "{description} | {module path}"
modules=(
    "List connected ADB devices | devices.sh"
    "Install APK to device | install-apk.sh"
    "Take screenshot of device |screenshot.sh"
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
    read -rp "Action: " input
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
module_path=$(echo "${parts[1]}" | sed 's/^[[:space:]]*//; s/[[:space:]]*$//')

echo -e ""

source "${BASH_SOURCE%/*}/$module_path"
