#!/bin/bash

DEVICE_FILE="/dev/input/by-path/platform-rg351-keys-event"

while true; do
    evtest "$DEVICE_FILE" | while read -r line; do
    if pgrep -f "/usr/bin/retrorun.sh" >/dev/null || pgrep -f "/roms/ports" >/dev/null || pgrep -f "/usr/local/bin/mupen64plus" >/dev/null ; then
        if [[ $line == *"KEY_ESC"* ]]; then
            if [[ $line == *"value 1"* ]]; then
                /usr/bin/adckeys.py startselect
            fi
        elif [[ $line == *"KEY_RIGHTSHIFT"* ]]; then
              if [[ $line == *"value 1"* ]]; then
                  /usr/bin/adckeys.py select
              fi
        elif [[ $line == *"KEY_ENTER"* ]]; then
              if [[ $line == *"value 1"* ]]; then
                  /usr/bin/adckeys.py start
              fi
        fi
    fi
    done
done