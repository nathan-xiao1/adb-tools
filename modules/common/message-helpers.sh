#!/bin/bash

success_msg() {
    echo -e "${FG_BOLD_GREEN}SUCCESS:${RESET} ${FG_GREEN}$1${RESET}"
}

error_msg() {
    echo -e "${FG_BOLD_RED}ERROR:${RESET} ${FG_RED}$1${RESET}"
}

warning_msg() {
    echo -e "${FG_BOLD_YELLOW}ERROR:${RESET} ${FG_YELLOW}$1${RESET}"
}

device_printf() {
    printf "${FG_DIM}%-18s${RESET} %b\n" "$1" "$2"
}
