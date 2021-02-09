#!/bin/sh

# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2019-present SumavisionQ5 (https://github.com/SumavisionQ5)
# Modifications by Shanti Gilbert (https://github.com/shantigilbert)
# Copyright (C) 2020-present Fewtarius

. /etc/profile


ROMNAME="$1"

if [ "$ROMNAME" == "shutdown" ]
then
  clear >/dev/console
  echo -ne "\033[10;26H" >/dev/console
  message_stream "GAME OVER" .05
  sleep .5
  exit 0
fi

if [ "$ROMNAME" == "intro" ] || [ "$ROMNAME" == "exit" ]
then
  if [ "$(cat /usr/config/.OS_ARCH)" == "RG351P" ]
  then
    SPLASH="/usr/config/splash/splash-480l.png"
  else
    SPLASH="/usr/config/splash/splash-1080.png"
  fi
else
  if [ "$(get_ee_setting ee_splash.enabled)" == "0" ]
  then
    exit 0
  fi
  MYGAME=${ROMNAME^^}
  MYBOOT="

       ### WELCOME TO \e[31m351\e[39mELEC  -  VERSION $(cat /storage/.config/.OS_VERSION) ###
       $(awk '/MemTotal/ {printf $2}' /proc/meminfo)K  BYTE RAM SYSTEM $(awk '/MemFree/ {printf $2}' /proc/meminfo)K BYTES FREE

"

  MYREADY="
READY."

  MYSTART="
LOAD \"${ROMNAME##*/}\""

  MYLOADING="

LOADING ${MYGAME##*/}
READY.
"
  clear >/dev/console;
  message_stream "${MYBOOT}" 0
  spinny_cursor "STARTING UP... " 6
  message_stream "${MYREADY}" 0
  message_stream "${MYSTART}" .02
  message_stream "${MYLOADING}" 0
  message_stream "RUN" .05
  exit 0
fi

[[ "${PLATFORM}" != "intro" ]] && VIDEO=0 || VIDEO=$(get_ee_setting ee_bootvideo.enabled)

if [[ -f "/storage/.config/distribution/configs/novideo" ]] && [[ ${VIDEO} != "1" ]]
then
        if [ "$PLATFORM" != "intro" ]; then
                /usr/bin/mpv "${SPLASH}" > /dev/null 2>&1 &
        fi
else
	# Show intro video
        SPLASH=${VIDEOSPLASH}
        set_audio alsa
        /usr/bin/mpv "$SPLASH" > /dev/null 2>&1
        touch "/storage/.config/distribution/configs/novideo"
fi

# Wait for the time specified in ee_splash_delay setting in distribution.conf
SPLASHTIME=$(get_ee_setting ee_splash.delay)
[ ! -z "$SPLASHTIME" ] && sleep $SPLASHTIME
