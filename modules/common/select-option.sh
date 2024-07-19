#!/bin/bash

_get_term_size() {
    # Get terminal size ('stty' is POSIX and always available).
    # This can't be done reliably across all bash versions in pure bash.
    read -r LINES COLUMNS < <(stty size)

    # Max list items that fit in the scroll area.
    ((max_items = LINES - 3))
}

_setup_terminal() {
    # Setup the terminal for the TUI.
    # '\e[?1049h': Use alternative screen buffer.
    # '\e[?7l':    Disable line wrapping.
    # '\e[?25l':   Hide the cursor.
    # '\e[2J':     Clear the screen.
    # '\e[1;Nr':   Limit scrolling to scrolling area.
    #              Also sets cursor to (0,0).
    printf '\e[?1049h\e[?7l\e[?25l\e[2J\e[1;%sr' "$max_items"

    # Hide echoing of user input
    stty -echo
}

_reset_terminal() {
    # Reset the terminal to a useable state (undo all changes).
    # '\e[?7h':   Re-enable line wrapping.
    # '\e[?25h':  Unhide the cursor.
    # '\e[2J':    Clear the terminal.
    # '\e[;r':    Set the scroll region to its default value.
    #             Also sets cursor to (0,0).
    # '\e[?1049l: Restore main screen buffer.
    printf '\e[?7h\e[?25h\e[2J\e[;r\e[?1049l'

    # Show user input.
    stty echo
}

_clear_screen() {
    # Only clear the scrolling window (dir item list).
    # '\e[%sH':    Move cursor to bottom of scroll area.
    # '\e[9999C':  Move cursor to right edge of the terminal.
    # '\e[1J':     Clear screen to top left corner (from cursor up).
    # '\e[2J':     Clear screen fully (if using tmux) (fixes clear issues).
    # '\e[1;%sr':  Clearing the screen resets the scroll region(?). Re-set it.
    #              Also sets cursor to (0,0).
    printf '\e[%sH\e[9999C\e[1J%b\e[1;%sr' \
        "$((LINES - 2))" "${TMUX:+\e[2J}" "$max_items"
}

# Function to display a text user interface for selecting an option
# Parameters: an array of options
select_option() {
    local prompt="$1"
    local options=("${@:2}")
    local selected=0

    _get_term_size
    _setup_terminal

    # Function to print the menu
    print_menu() {
        _clear_screen
        echo -e "${FG_DIM}[Use the UP and DOWN arrow key to make a selection and Enter to select]${RESET}"
        echo -e ""
        echo -e "$prompt:"
        echo -e ""
        for i in "${!options[@]}"; do
            if [[ $i -eq $selected ]]; then
                echo -e " ${FG_BLUE}>${RESET} ${options[$i]}"
            else
                echo -e "   ${FG_DIM}${options[$i]}${RESET}"
            fi
        done
    }

    # Initial menu print
    print_menu

    # Capture user input
    while true; do
        read -rsn1 input

        case $input in
        $'\x1b') # ESC sequence
            read -rsn2 input
            case $input in
            '[A') # Up arrow
                if [ $selected -gt 0 ]; then
                    ((selected--))
                fi
                ;;
            '[B') # Down arrow
                if [ $selected -lt $((${#options[@]} - 1)) ]; then
                    ((selected++))
                fi
                ;;
            esac
            ;;
        '') # Enter key
            break
            ;;
        esac

        print_menu
    done

    _reset_terminal

    # Output the selected option index
    return $selected
}
