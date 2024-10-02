#!/bin/bash

BRANCH="master"

ADB_TOOLS_REPO_DIR="$1"

ADB_TOOLS_DIR="/var/tmp/adb-tools"

# Files to store the last update check timestamp
LAST_UPDATE_CHECK_FILENAME=".last_update_check"
LAST_UPDATE_CHECK_FILEPATH="$ADB_TOOLS_DIR/$LAST_UPDATE_CHECK_FILENAME"

CHECK_FREQUENCY_S=604800 # 7 days in seconds

# Change directory to the ADB-Tools' repo directory
cd "$ADB_TOOLS_REPO_DIR" || return 1

# Check if Git is installed
if ! git -v >/dev/null 2>&1; then
    echo -e "${FG_YELLOW}Git not installed. ADB-Tools won't auto check for update.${RESET}"
    return 0
fi

# Check if the current branch is the target branch
if [[ $(git rev-parse --abbrev-ref HEAD) != "$BRANCH" ]]; then
    echo -e "${FG_YELLOW}Not on $BRANCH - skipping update check${RESET}"
    return 0
fi

if [[ -d "$ADB_TOOLS_DIR" ]]; then
    mkdir -p /var/tmp/adb-tools
fi

# Get the last update check timestamp
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

# Fetch the latest changes from remote
git fetch origin --quiet

# Get the current local hash of the branch
LOCAL_HASH=$(git rev-parse HEAD)

# Get the latest hash from the remote branch
REMOTE_HASH=$(git rev-parse origin/$BRANCH)

# Update the last check timestamp
echo "$current_timestamp" >"$LAST_UPDATE_CHECK_FILEPATH"

# Compare the local and remote hashes to check for updates
if [ "$LOCAL_HASH" != "$REMOTE_HASH" ]; then
    # Ask for user confirmation
    echo -ne "${FG_YELLOW}An update is available for ADB-Tools. Do you want to upgrade now? [Y/n] ${RESET}"
    read -n 1 -r REPLY
    echo # Move to a new line

    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo -e "Updating ADB-Tools..."
        git pull origin $BRANCH --quiet
        if [ $? -eq 0 ]; then
            echo ""
            echo -e "${FG_GREEN}ADB-Tools has been updated to the latest version!${RESET}"
        else
            echo ""
            echo -e "${FG_RED}Failed to update ADB-Tools${RESET}"
            return 1
        fi
    fi
else
    echo -e "${FG_CYAN}ADB-Tools is up-to-date. ${RESET}"
fi
