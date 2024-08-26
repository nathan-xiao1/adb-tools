#!/bin/bash

_find_sdk_path() {
    curDir=$(pwd)
    if [ -f "$curDir/local.properties" ]; then
        sdkDir=$(awk '/^sdk.dir/ {print $1}' local.properties | cut -d '=' -f2)
    fi

    if [ ! -d "$sdkDir" ]; then
        sdkDir=${ANDROID_HOME}
    fi

    if [ ! -d "$sdkDir" ]; then
        sdkDir=${HOME}/Android/sdk
    fi
    echo "$sdkDir"
}

_aapt_dump() {
    apkPath=$1
    key=$2
    aapt_command=$(aapt_command)
    result=$(${aapt_command} d badging "$apkPath" | grep "$key" | awk '{gsub("name=|'"'"'", ""); print $2}')
    echo "$result"
}

_aapt_command() {
    aapt_command=$(which aapt)
    if [ $? != 0 ]; then
        aapt_command=$(set_aapt_path)
    fi
    echo "$aapt_command"
}

_set_aapt_path() {
    sdkDir=$(find_sdk_path)
    buildToolsPath="$sdkDir/build-tools"
    for file in $(ls -r $buildToolsPath); do
        aaptFile="$buildToolsPath/$file/aapt"
        if [ -f "$aaptFile" ]; then
            echo "$aaptFile"
            break
        fi
    done
}

_get_launcher_activity() {
    local apkPath=$1
    aapt_command=$(aapt_command)
    manifestData=$(${aapt_command} dump xmltree "$apkPath" AndroidManifest.xml)
    indicatorLines=$(echo "$manifestData" | grep -n 'android:name(.*)="android.intent.category.LAUNCHER"' | awk -F ":" '{print $1}')
    launcherActivity=""
    for indicator in $indicatorLines; do
        local foundIntentFilter=false
        for ((i = $indicator; i >= 0; i--)); do
            lineContent=$(echo "$manifestData" | sed -n "${i}p")
            if [[ "$foundIntentFilter" == true ]]; then
                match=$(echo "$lineContent" | grep 'E:.*activity')
                if [ -n "$match" ]; then
                    break
                fi
                match=$(echo "$manifestData" | sed -n "${i}p" | awk '/android:targetActivity/{gsub("\"",""); print}' | cut -d '=' -f2 | cut -d ' ' -f1)
                if [[ -n "$match" ]] && [[ "$match" != *.LeakActivity ]]; then
                    launcherActivity="$match"
                    break 2
                fi
            else
                intentFilter=$(echo "$lineContent" | grep 'intent-filter')
                if [ -n "$intentFilter" ]; then
                    foundIntentFilter=true
                fi
            fi
        done
    done

    if [ ! -n "$launcherActivity" ]; then
        launcherActivity=$(aapt_dump "$apkPath" 'launchable-activity')
    fi
    echo "$launcherActivity"
}

_get_adb_devices() {
    local devices=()
    local no_wireless=false

    if [ "$1" == "--no-wireless" ]; then
        no_wireless=true
    fi

    while IFS='' read -r line; do
        if $no_wireless && [[ "$line" == *":"* ]]; then
            continue
        fi
        devices+=("$line")
    done < <(adb devices | grep -v "List of devices" | cut -f1)

    echo "${devices[@]}"
}

export -f _aapt_dump _get_launcher_activity _get_adb_devices
