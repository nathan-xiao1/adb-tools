#!/bin/bash

BRANCH="master"

ADB_TOOLS_DIR="/var/tmp/adb-tools"

LAST_UPDATE_CHECK_FILENAME=".last_update_check"
LAST_UPDATE_CHECK_FILEPATH="$ADB_TOOLS_DIR/$LAST_UPDATE_CHECK_FILENAME"

CHECK_FREQUENCY_S=604800 # 7 days in seconds

if ! git -v >/dev/null 2>&1; then
    echo -e "${FG_YELLOW}Git not installed. ADB-Tools won't auto check for update.${RESET}"
    return 0
fi

if [[ -d "$ADB_TOOLS_DIR" ]]; then
    mkdir -p /var/tmp/adb-tools
fi

# Get the last update date
if [ -f "$LAST_UPDATE_CHECK_FILEPATH" ]; then
    last_check_timestamp=$(cat "$LAST_UPDATE_CHECK_FILEPATH")
else
    last_check_timestamp=0
fi

current_timestamp=$(date +%s)

# # Don't check for update if we have already check within the last `CHECK_FREQUENCY_S` seconds
if [[ $((current_timestamp - last_check_timestamp)) -le CHECK_FREQUENCY_S ]]; then
    return 0
fi

echo -e "Checking for update..."

# Fetch the latest changes from remote without merging
git fetch origin >/dev/null 2>&1

# Get the current local hash of the branch
LOCAL_HASH=$(git rev-parse HEAD)

# Get the latest hash from the remote branch
REMOTE_HASH=$(git rev-parse origin/$BRANCH)

LOCAL_HASH=$(git rev-parse HEAD)

echo "$current_timestamp" >"$LAST_UPDATE_CHECK_FILEPATH"

# Compare the hashes
if [ "$LOCAL_HASH" != "$REMOTE_HASH" ]; then
    # Ask for user confirmation
    echo -ne "${FG_YELLOW}An update is available for ADB-Tools. Do you want to upgrade now? [Y/n] ${RESET}"
    read -n 1 -r REPLY
    echo # Move to a new line

    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo -e "Updating ADB-Tools..."
        # git pull origin $BRANCH
        if [ $? -eq 0 ]; then
            echo ""
            echo -e "${FG_GREEN}ADB-Tools has been updated to the latest version!${RESET}"
        else
            echo ""
            echo -e "${FG_RED}Failed to update ADB-Tools${RESET}"
            exit 1
        fi
    fi
else 
    echo -e "${FG_CYAN}ADB-Tools is up-to-date. ${RESET}"
fi
