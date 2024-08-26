#!/bin/bash
script_dir=$(dirname -- "$(readlink -f -- "$BASH_SOURCE")")

source "$script_dir/modules/common/ansi-escape-codes.sh"

# Install for zsh
if [[ -f ~/.zshrc ]]; then
    if ! grep -q "alias adb-tools=" ~/.zshrc; then
        echo "" >>~/.zshrc
        echo "source $script_dir/_adb_tools_completion.sh" >>~/.zshrc
        echo "export PATH=\${PATH}:\"$script_dir\"" >>~/.zshrc
        echo -e "${FG_GREEN}Installed adb-tools for zsh${RESET}"
    else
        echo -e "${FG_YELLOW}adb-tools already installed for zsh${RESET}"
    fi
fi

# Install for bash
if [[ -f ~/.bashrc ]]; then
    if ! grep -q "alias adb-tools=" ~/.bashrc; then
        echo "" >>~/.bashrc
        echo "source $script_dir/_adb_tools_completion.sh" >>~/.bashrc
        echo "export PATH=\${PATH}:\"$script_dir\"" >>~/.bashrc
        echo -e "${FG_GREEN}Installed adb-tools for bash${RESET}"
    else
        echo -e "${FG_YELLOW}adb-tools already installed for bash${RESET}"
    fi
fi
