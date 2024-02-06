#!/bin/bash
##
## This script should only run after an update
##
## Config Files
CONF="/storage/.config/distribution/configs/distribution.conf"
RACONF="/storage/.config/retroarch/retroarch.cfg"
LAST_UPDATE_FILE="/storage/.lastupdateversion"
DEVICE="$(cat /storage/.config/.OS_ARCH)"
ECWOLFCONF="/storage/.config/distribution/ecwolf/ecwolf.cfg"

# 2021-12-15
## Parse LAST_UPDATE_VERSION.  This variable will be the date of the previous upgrade. Ex: 20211222.
## - This variable can be used to execute upgrade logic only when crossing a version threshold.
##   - Greater than/less than checks should always be used to avoid assuming a user is coming from a specific version.
##   - Logic should still work if run multiple times in case of upgrade/downgrade/upgrade scenario.
## - For versions prior to the addition of .lastupdateversion (pineapple forest, etc), this number will be 0.
## - For versions which can't be parsed (custom builds), the number will be set to all 9's so it is greater than all dates
LAST_UPDATE_VERSION="0"
if [[ -f "${LAST_UPDATE_FILE}" ]]; then

  #The following parsing should work for all the below permuations: (anything with 8 digits as a date)
  #
  # PR: pr-740-2021-12-04-20211208_1753-3781bcc
  # Beta: beta-20211130_1728
  # Prerelease: prerelease-20211130_1728
  # Release: 20211122
  # Release - patch: 20211122-1
  PATTERN='.*([0-9]{8}).*'
  LAST_UPDATE_VERSION="$(cat "$LAST_UPDATE_FILE" | grep -E "$PATTERN" | sed -E "s|$PATTERN|\1|g" )"

  # If we cannot parse last update version - set to large date that will never execute - this prevents dev versions causing strangeness
  if [[ -z "${LAST_UPDATE_VERSION}" ]]; then
    LAST_UPDATE_VERSION="99999999"
  fi
fi
echo "last update version: ${LAST_UPDATE_VERSION}"

## 2023-01-15 
## Add all JoyAxis[]Deadzone values to ECWolf due to default deadzones being too low.
if [ -e "${ECWOLFCONF}" ]; then
        for i in {0..6}
        do
                sed -i "s/JoyAxis${i}Deadzone = .*/JoyAxis${i}Deadzone = 4;/g" ${ECWOLFCONF}
        done
fi

## 2023-01-09
## check for audio/video filter dir in retroarch.cfg
if ! grep -q "^audio_filter_dir" ${RACONF}; then
  echo 'audio_filter_dir = "/usr/share/retroarch/filters/audio"' >> ${RACONF}
fi
if ! grep -q "^video_filter_dir" ${RACONF}; then
  echo 'video_filter_dir = "/usr/share/retroarch/filters/video"' >> ${RACONF}
fi

## 2022-12-29
## remove amiberry controller folder
if [[ "$LAST_UPDATE_VERSION" -le "20221230" ]]; then
  rm -rf /storage/.config/amiberry/controller
fi

## 2022-12-28
## clear mame/arcade autosave=0
if [[ "$LAST_UPDATE_VERSION" -le "20221229" ]]; then
  sed -i '/arcade.autosave=0/d;' /storage/.config/distribution/configs/distribution.conf
  sed -i '/mame.autosave=0/d;' /storage/.config/distribution/configs/distribution.conf
fi

## 2022-12-24
## Reset RG351P volume to 100% (device has no soft-volume buttons)
if [[ "$DEVICE" == "RG351P" ]]; then
  sed -i 's/audio.volume=.*/audio.volume=100/g' /storage/.config/distribution/configs/distribution.conf
fi

## 2022-12-29
## clear yabasanshiro control configs
if [[ "$LAST_UPDATE_VERSION" -le "20221230" ]]; then
  rm -rf /storage/roms/saturn/yabasanshiro/keymapv2.json
  rm -rf /storage/roms/saturn/yabasanshiro/input.cfg
fi

## 2022-05-19
## Move any existing scummvm save data the scummvm system folder
if [[ -d "/storage/.local/share/scummvm/saves" ]]; then
    mkdir -p /storage/roms/scummvm/saves
    mv /storage/.local/share/scummvm/saves/* /storage/roms/scummvm/saves
    rmdir /storage/.local/share/scummvm/saves
fi

## 2022-05-19
## update scummvm aux-data
rm -rf /storage/roms/bios/scummvm/theme
rm -rf /storage/roms/bios/scummvm/extra
mkdir -p /storage/roms/bios/scummvm
cp -rf /usr/share/scummvm/* -d /storage/roms/bios/scummvm

## 2022-04-12:
## Clear OpenBOR data folder
if [ -d /storage/openbor ]; then
  if [ ! -f /storage/openbor/.openbor_20220412 ]; then
    rm -rf /storage/openbor
    mkdir /storage/openbor
    touch /storage/openbor/.openbor_20220412
  fi
fi

## 2022-04-04
## enforce update of retrorun.cfg and reotrarch-core-options.cfg
cp -rf /usr/config/retroarch/retroarch-core-options.cfg /storage/roms/gamedata/retroarch/retroarch-core-options.cfg
cp -rf /usr/config/distribution/configs/retrorun.cfg /storage/.config/distribution/configs/retrorun.cfg

## 2022-04-04
## enable new frameskip option for flycast core
if [[ "$LAST_UPDATE_VERSION" -le "20220405" ]]; then
  rm -rf /storage/roms/gamedata/retroarch/config/Flycast/Flycast.opt
fi

## 2022-03-16
## Move any existing scummvm data from gamedata to the scummvm system folder
if [[ -d "/storage/roms/scummvm" ]]; then
  if [[ -d "/storage/roms/gamedata/scummvm/games" ]]; then
    rm -rf "/storage/roms/gamedata/scummvm/games/_Scan ScummVM Games.sh"
    mv /storage/roms/gamedata/scummvm/games/* /storage/roms/scummvm
    rmdir /storage/roms/gamedata/scummvm/games
  fi
fi

## 2022-03-16
## Disable splash screen
  sed -i 's/ee_splash.enabled=1/ee_splash.enabled=0/g;' ${CONF}

## 2022-03-14
## Switch default theme when coming from pineapple forrest or prereleases after pineapple forrest
## For users from pineapple forrest - do a one time switch of default theme to es-theme-art-book-next
if [[ "$LAST_UPDATE_VERSION" -le "20220314" ]]; then
  sed -i 's/value="es-theme-art-book-3-2"/value="es-theme-art-book-next-default"/g;
          s/value="es-theme-art-book-4-3"/value="es-theme-art-book-next-default"/g' /storage/.config/emulationstation/es_settings.cfg
fi

## 2022-03-12
## Move any existing daphne data from daphne to laserdisc system (if laserdisc system is empty)
if [[ -d "/storage/roms/daphne" ]] && [[ "$(ls -A /storage/roms/daphne/*.daphne)" ]]; then
  if [[ -d "/storage/roms/laserdisc/roms" ]] && [[ ! "$(ls -A /storage/roms/laserdisc/roms)" ]]; then
    rmdir /storage/roms/laserdisc/roms
  fi
  if [ ! "$(ls -A /storage/roms/laserdisc)" ]; then
    mkdir /storage/roms/laserdisc/roms
    mv /storage/roms/daphne/*.daphne /storage/roms/laserdisc
    mv /storage/roms/daphne/roms /storage/roms/laserdisc
    mv /storage/roms/daphne/images /storage/roms/laserdisc
    mv /storage/roms/daphne/videos /storage/roms/laserdisc
    mv /storage/roms/daphne/gamelist.xml /storage/roms/laserdisc
    rm -rf /storage/roms/daphne
    rm /storage/.config/distribution/configs/hypseus/roms
    ln -fs /storage/roms/laserdisc/roms /storage/.config/distribution/configs/hypseus/roms
    rm /storage/.config/distribution/configs/hypseus/singe
    ln -fs /storage/roms/laserdisc/roms /storage/.config/distribution/configs/hypseus/singe
  fi
elif [[ -d "/storage/roms/laserdisc/sound" ]]; then
  rm -rf /storage/roms/laserdisc/sound
fi

## 2022-03-09
## Force update of /storage/roms/bios/freej2me-lr.jar to latest version
cp -rf /usr/config/distribution/freej2me/freej2me-lr.jar /storage/roms/bios

## 2022-02-20
## Delete old hypseus folder after upgrading to hypseus-singe
if [[ ! -f "/storage/.config/distribution/configs/hypseus/.hypseus-singe" ]]; then
  rm -rf /storage/.config/distribution/configs/hypseus
  cp -rf /usr/config/distribution/configs/hypseus /storage/.config/distribution/configs/
  touch /storage/.config/distribution/configs/hypseus/.hypseus-singe
fi

## 2022-02-11
## During the beta period, the RG552 used a 'softvol' plugin for asound due to sound issues in kernel
## This reverts it as new kernel supports sound playback.  We only want to revert once as it's moderately supported to
## update your asound.conf manually.
##
## Additionally, DAC is the name of playback device instead of Playback, so update that in es_settings.
if [[ "$DEVICE" == "RG552" && "$LAST_UPDATE_VERSION" -le "20220211" ]]; then
  cp /usr/config/asound.conf /storage/.config/asound.conf
  sed -i 's/name="AudioDevice" value="Playback"/name="AudioDevice" value="DAC"/g' /storage/.config/emulationstation/es_settings.cfg
fi

# 2021-11-03 (konsumschaf)
# Remove the 2 minutes popup setting from distribution.conf
# Remove old setting for popup (notification.display_time)
sed -i '/int name="audio.display_titles_time" value="120"/d;
        /int name="notification.display_time"/d;
       ' /storage/.config/emulationstation/es_settings.cfg

# set savestate_thumbnail_enable = true (required for savestate menu in ES)
sed -i "/savestate_thumbnail_enable =/d" ${RACONF}
echo "savestate_thumbnail_enable = "true"" >> ${RACONF}

# Sync ES locale only after update
if [ ! -d "/storage/.config/emulationstation/locale" ]
then
  rsync -a /usr/config/locale/ /storage/.config/emulationstation/locale/ &
else
  rsync -a --delete /usr/config/locale/ /storage/.config/emulationstation/locale/ &
fi

# Sync ES resources after update
if [ ! -d "/storage/.config/emulationstation/resources" ]
then
  rsync -a /usr/config/emulationstation/resources/ /storage/.config/emulationstation/resources/ &
else
  rsync -a --delete /usr/config/emulationstation/resources/ /storage/.config/emulationstation/resources/ &
fi

## 2021-10-07
## Copy es_input.cfg over on every update
## This prevents a user with an old es_input from getting the 'input config scree'
### I don't believe there is a use case where a user needed to customize es_input.xml intentionally
if [ -f /usr/config/emulationstation/es_input.cfg ]; then
	cp /usr/config/emulationstation/es_input.cfg /storage/.emulationstation/
fi

## 2021-10-04
## Remove old bezel configs
### Done in a single sed to keep performance fast
sed -i '/global.bezel=0/d;
        /gb.bezel=351ELEC-Gameboy/d;
        /gamegear.bezel=351ELEC-Gamegear/d;
        /gbc.bezel=351ELEC-GameboyColor/d;
        /pokemini.bezel=351ELEC-PokemonMini/d;
        /supervision.bezel=351ELEC-Supervision/d;
        ' /storage/.config/distribution/configs/distribution.conf

## 2021-12-15
## Do not break automatic bezel support for users upgrading from pineapple forrest.
## Pineapple Forest bezels assumed 'auto' would mean 'on', but should be 'off'
### - Doing this after other bezel changes from 2021-10-04 so empty values are consistent for upgrades prior to pineapple forrest.
### - Only running for versions less than current date - this ensures if user sets to 'auto' after upgrade, settings will be 'off' as desired
if [[ "$LAST_UPDATE_VERSION" -le "20211215" ]]; then
  grep -qF 'global.bezel=' "${CONF}"|| echo 'global.bezel=default' >> "${CONF}"

  grep -qF 'gamegear.bezel.overlay.grid=' "${CONF}"|| echo 'gamegear.bezel.overlay.grid=1' >> "${CONF}"
  grep -qF 'gamegear.bezel.overlay.shadow=' "${CONF}"|| echo 'gamegear.bezel.overlay.shadow=1' >> "${CONF}"

  grep -qF 'gb.bezel.overlay.grid=' "${CONF}"|| echo 'gb.bezel.overlay.grid=1' >> "${CONF}"
  grep -qF 'gb.bezel.overlay.shadow=' "${CONF}"|| echo 'gb.bezel.overlay.shadow=1' >> "${CONF}"

  grep -qF 'gbc.bezel.overlay.grid=' "${CONF}"|| echo 'gbc.bezel.overlay.grid=1' >> "${CONF}"
  grep -qF 'gbc.bezel.overlay.shadow=' "${CONF}"|| echo 'gbc.bezel.overlay.shadow=1' >> "${CONF}"

  grep -qF 'ngp.bezel.overlay.grid=' "${CONF}"|| echo 'ngp.bezel.overlay.grid=1' >> "${CONF}"
  grep -qF 'ngp.bezel.overlay.shadow=' "${CONF}"|| echo 'ngp.bezel.overlay.shadow=1' >> "${CONF}"

  grep -qF 'ngpc.bezel.overlay.grid=' "${CONF}"|| echo 'ngpc.bezel.overlay.grid=1' >> "${CONF}"
  grep -qF 'ngpc.bezel.overlay.shadow=' "${CONF}"|| echo 'ngpc.bezel.overlay.shadow=1' >> "${CONF}"

  grep -qF 'pokemini.bezel.overlay.grid=' "${CONF}"|| echo 'pokemini.bezel.overlay.grid=1' >> "${CONF}"
  grep -qF 'pokemini.bezel.overlay.shadow=' "${CONF}"|| echo 'pokemini.bezel.overlay.shadow=1' >> "${CONF}"

  grep -qF 'supervision.bezel.overlay.grid=' "${CONF}"|| echo 'supervision.bezel.overlay.grid=1' >> "${CONF}"
  grep -qF 'supervision.bezel.overlay.shadow=' "${CONF}"|| echo 'supervision.bezel.overlay.shadow=1' >> "${CONF}"

  grep -qF 'wonderswan.bezel.overlay.grid=' "${CONF}"|| echo 'wonderswan.bezel.overlay.grid=1' >> "${CONF}"
  grep -qF 'wonderswan.bezel.overlay.shadow=' "${CONF}"|| echo 'wonderswan.bezel.overlay.shadow=1' >> "${CONF}"
fi

## 2021-09-30:
## Remove any configurd ES joypads on upgrade
if [ ! -f /storage/joypads/dont_delete_me ]; then
  rm -f /storage/joypads/*.cfg
fi

## 2021-09-27:
## Force replacement of gamecontrollerdb.txt on update
cp -f /usr/config/SDL-GameControllerDB/gamecontrollerdb.txt /storage/.config/SDL-GameControllerDB/gamecontrollerdb.txt

## 2021-09-19:
## Replace libretro settings in distribution.conf
sed -i 's/.emulator=libretro/.emulator=retroarch/g' /storage/.config/distribution/configs/distribution.conf

## 2021-09-17:
## Reset advanemame config
if [ -d /storage/.advance ]; then
  rm -rf /storage/.advance/advmame.rc
fi

## 2021-08-01:
## Check swapfile size and delete it if necessary
. /etc/swap.conf
if [ -f "$SWAPFILE" ]; then
  if [ $(ls -l "$SWAPFILE" | awk '{print  $5}') -lt $(($SWAPFILESIZE*1024*1024)) ]; then
    swapoff "$SWAPFILE"
    rm -rf "$SWAPFILE"
  fi
fi

## 2021-07-27 (konsumschaf)
## Copy es_features.cfg over on every update
if [ -f /usr/config/emulationstation/es_features.cfg ]; then
	cp /usr/config/emulationstation/es_features.cfg /storage/.emulationstation/.
fi

## 2021-07-24 (konsumschaf)
## Remove all settings from retroarch.cfg that are set in setsettings.py
## Retroarch uses the settings in retroarch.cfg if there is an override file that misses them
/usr/bin/clear-retroarch.sh

## 2021-07-25:
## Remove package drastic if still installed
if [ -x /storage/.config/packages/drastic/uninstall.sh ]; then
        /usr/bin/amberelec-es-packages remove drastic
fi
# forced drastic removal to allow upgrade after every image update
if [ ! -d "/storage/roms/gamedata/drastic" ]
then
  mkdir -p "/storage/roms/gamedata/drastic"
  ln -sf /storage/roms/gamedata/drastic /storage/drastic
else
  rm -f /storage/roms/gamedata/drastic/drastic.sh
  rm -f /storage/roms/gamedata/drastic/aarch64/drastic/drastic
fi

## 2021-07-02 (konsumschaf)
## Change the settings for global.retroachievements.leaderboards
if grep -q "global.retroachievements.leaderboards=0" ${CONF}; then
	sed -i "/global.retroachievements.leaderboards/d" ${CONF}
	echo "global.retroachievements.leaderboards=disabled" >> ${CONF}
elif grep -q "global.retroachievements.leaderboards=1" ${CONF}; then
	sed -i "/global.retroachievements.leaderboards/d" ${CONF}
	echo "global.retroachievements.leaderboards=enabled" >> ${CONF}
fi

## 2021-05-27
## Enable D-Pad to analogue at boot until we create a proper toggle
sed -i "/## Enable D-Pad to analogue at boot until we create a proper toggle/d" /storage/.config/distribution/configs/distribution.conf
sed -i "/global.analogue/d" /storage/.config/distribution/configs/distribution.conf
echo '## Enable D-Pad to analogue at boot until we create a proper toggle' >> /storage/.config/distribution/configs/distribution.conf
echo 'global.analogue=1' >> /storage/.config/distribution/configs/distribution.conf

## 2021-05-17:
## Remove mednafen core files from /tmp/cores
if [ "$(ls /tmp/cores/mednafen_* | wc -l)" -ge "1" ]; then
	rm /tmp/cores/mednafen_*
fi

## 2021-05-17:
## Remove package solarus if still installed
if [ -x /storage/.config/packages/solarus/uninstall.sh ]; then
	/usr/bin/amberelec-es-packages remove solarus
fi

## 2021-05-12:
## After PCSX-ReARMed core update
## Cleanup the PCSX-ReARMed core remap-files, they are not needed anymore
if [ -f /storage/.config/remappings/PCSX-ReARMed/PCSX-ReARMed.rmp ]; then
	rm /storage/.config/remappings/PCSX-ReARMed/PCSX-ReARMed.rmp
fi

if [ -f /storage/roms/gamedata/remappings/PCSX-ReARMed/PCSX-ReARMed.rmp ]; then
	rm /storage/roms/gamedata/remappings/PCSX-ReARMed/PCSX-ReARMed.rmp
fi

## 2021-05-15:
## MC needs the config
if [[ -z $(ls -A /storage/.config/mc/) ]]; then
	rsync -a /usr/config/mc/* /storage/.config/mc
fi

## 2021-05-15:
## Remove retrorun package if still installed
if [ -x /storage/.config/packages/retrorun/uninstall.sh ]; then
	/usr/bin/amberelec-es-packages remove retrorun
fi

## Moved over from /usr/bin/autostart.sh
## Migrate old emuoptions.conf if it exist
if [ -e "/storage/.config/distribution/configs/emuoptions.conf" ]
then
	echo "# -------------------------------" >> /storage/.config/distribution/configs/distribution.conf
	cat /storage/.config/distribution/configs/emuoptions.conf >> /storage/.config/distribution/configs/distribution.conf
	echo "# -------------------------------" >> /storage/.config/distribution/configs/distribution.conf
	mv /storage/.config/distribution/configs/emuoptions.conf /storage/.config/distribution/configs/emuoptions.conf.bak
fi

## Moved over from /usr/bin/autostart.sh
## Save old es_systems.cfg in case it is still needed
if [ -f /storage/.config/emulationstation/es_systems.cfg ]; then
	mv /storage/.config/emulationstation/es_systems.cfg\
	   /storage/.config/emulationstation/es_systems.oldcfg-rename-to:es_systems_custom.cfg-if-needed
fi

## Moved over from /usr/bin/autostart.sh
## Copy after new installation / missing logo.png
if [ "$(cat /usr/config/.OS_ARCH)" == "RG351P" ]; then
	cp -f /usr/config/splash/splash-480l.png /storage/.config/emulationstation/resources/logo.png
elif [ "$(cat /usr/config/.OS_ARCH)" == "RG351V" ] || [ "$(cat /usr/config/.OS_ARCH)" == "RG351MP" ]; then
	cp -f /usr/config/splash/splash-640.png /storage/.config/emulationstation/resources/logo.png
elif [ "$(cat /usr/config/.OS_ARCH)" == "RG552" ]; then
	cp -f /usr/config/splash/splash-1920l.png /storage/.config/emulationstation/resources/logo.png
fi

## clear faulty lines from distribution.conf
sed -i 's/^=$//g' /storage/.config/distribution/configs/distribution.conf

## Just to know when the last update took place
echo Last Update: `date -Iminutes` > /storage/.lastupdate

## Allows only performing updates from specific versions
echo $(cat /storage/.config/.OS_VERSION) > "${LAST_UPDATE_FILE}"

# Clear Executing postupdate... message
echo -ne "\033[$1;$1H" >/dev/console
echo "                       " > /dev/console
