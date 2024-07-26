#!/bin/bash
script_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)

source "$script_dir/modules/common/ansi-escape-codes.sh"

# Install for zsh
if [[ -f ~/.zshrc ]]; then
    if ! grep -q "alias adb-tools=" ~/.zshrc; then
        echo "" >>~/.zshrc
        echo "alias adb-tools='(cd $script_dir && ./adb-tools.sh)'" >>~/.zshrc
        echo -e "${FG_GREEN}Installed adb-tools for zsh${RESET}"
    else
        echo -e "${FG_YELLOW}adb-tools already installed for zsh${RESET}"
    fi
fi

# Install for bash
if [[ -f ~/.bashrc ]]; then
    if ! grep -q "alias adb-tools=" ~/.bashrc; then
        echo "alias adb-tools='(cd $PWD && ./adb-tools.sh)'" >>~/.bashrc
        echo -e "${FG_GREEN}Installed adb-tools for bash${RESET}"
    else
        echo -e "${FG_YELLOW}adb-tools already installed for bash${RESET}"
    fi
fi
