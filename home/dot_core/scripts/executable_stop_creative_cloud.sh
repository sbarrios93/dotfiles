#!/usr/bin/env bash
#
# Copyright (c) 2020,2021: Jacob.Lundqvist@gmail.com
# License: MIT
#
# Part of https://github.com/jaclu/Stop_CreativeCloud
#
# Version: 1.5.0 2021-10-30
#       Added check to ensure pgrep is available
#       Updated list of what to kill and order
#       Added -f to pgrep to search against full argument list
#       Improved conditions for what processes not to kill
#       Displays notification if adobe processes are still runing,
#       param -v will display them
#   1.4.0 2021-08-30
#       Program logic rewritten, now aborts if Lightroom / Photoshop
#       is running,
#   1.2.4 2021-04-07
#       Putting venv removal at start of script, to ensure
#   1.3.0  2021-03-19
#       Updated to cover latest Creative Cloud.app
#   1.2.3  2020-12-25
#       Added this header
#   1.2.2  2020-07-19
#       Added new creative cloud process to removal list
#
#  To terminate all of the Creative cloud background processes on a Mac,
#  when on battery power for a long time this will save quite a bit of power,
#
#  Will not proceed if Lightroom or Photoshop is runnig
#

if [ -z "$(which pgrep)" ]; then
    echo "ERROR: missing dependency pgrep!"
    exit 1
fi

BLOCKING_APPS=(
    "Adobe Lightroom"
    "Adobe Lightroom Classic"
    "Adobe Photoshop"
    "Adobe Illustrator"
)

blockers=()
for blocking_app in "${BLOCKING_APPS[@]}"; do
    pgrep -q "$blocking_app" && blockers+=("\"$blocking_app\"")
done

if ((${#blockers[@]})); then
    echo "${blockers[*]} running, this will be aborted"
    exit 1
fi

echo
echo "========================================"
echo "If some process needs elevated privs to kill,"
echo " you might be prompted for your password"
echo

#
# Since the appnames are not always enough to identify the right process,
# we use a dict with enouch of the command line
# to ensure we get the right one.
#
# This is Bash 3 notation, should hopefully also work for Bash 4
# Array pretending to be a Pythonic dictionary

CREATIVE_CLOUD_APPS=(

    #AGMService
    #AGSService
    #AccFin
    "Adobe CEF Helper"
    "Creative Cloud" # < 12[3]
    CrashHandler     # < 1
    AdobeCRDaemon    # < 1
    #AdobeIPCBroker
    "Adobe Desktop Service" # < 1
    #"CCLibrary.app/Contents/MacOS/../libs/node"
    "Core Sync"             # < 1
    com.adobe.acc.installer # < sudo: 1
    # It seems the rest can be ignored
    #"Creative Cloud Helper"
    #Adobe_CCXProcess.node
    #"Adobe Installer"
    #AdobeExtensionsService
    #ACCFinderSync
)

for app in "${CREATIVE_CLOUD_APPS[@]}"; do

    header_displayed=0
    for pid in $(pgrep -f "$app"); do
        if [ $header_displayed -eq 0 ]; then
            echo -n "Terminating any processes with this on its cmd-line: $app "
            header_displayed=1
        fi

        # shellcheck disable=SC2009
        cmd="$(ps exo pid=,command= -p $pid)"
        if [ -z "$cmd" ]; then
            echo "[pid gone: $pid]"
            continue # process gone
        elif ! echo "$cmd" | grep -qi "/Adobe" && ! echo "$cmd" | grep -qi com.adobe.acc; then
            echo
            echo "ERROR: ($pid) was not recognized as an Adobe app, ignoring it"
            echo "proc: [$cmd]"
            exit 1
            continue
        fi
        if ! kill -9 "$pid" 2>/dev/null; then
          echo "Failed to kill ($pid)"
        else
            echo -n "."
        fi
    done
    [ $header_displayed -eq 1 ] && echo
done

remaining="$(ps axu | grep -i adobe | grep -v grep)"
if [ -n "$remaining" ]; then
    echo
    echo "=====   Notice: Adobe stuff still running!   ====="
    echo
    if [ "$1" = "-v" ]; then
        echo "$remaining"
    else
        echo "run with -v to display remainders"
    fi
    echo
fi
