# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2019-present Shanti Gilbert (https://github.com/shantigilbert)
# Copyright (C) 2020-present Fewtarius
# Copyright (C) 2021-present AmberELEC (https://github.com/AmberELEC)

PKG_NAME="amberelec"
PKG_VERSION="1.0"
PKG_LICENSE="GPLv3"
PKG_DEPENDS_TARGET="toolchain ${OPENGLES} emulationstation retroarch retrorun klbi lib32"
PKG_LONGDESC="AmberELEC Meta Package"
PKG_TOOLCHAIN="make"

if [[ "${BASE_BUILD}" == "true" ]];
then
  PKG_EMUS=""
else
  LIBRETRO_CORES="81 a5200 arduous atari800 beetle-gba beetle-lynx beetle-ngp beetle-pce beetle-pce-fast beetle-pcfx beetle-supafaust beetle-supergrafx beetle-vb beetle-wswan bluemsx cap32 crocods \
                  dosbox-core dosbox-pure easyrpg emuscv ep128emu fake08 fbalpha2012 fbalpha2019 fbneo fceumm flycast flycast2021 fmsx freechaf freeintv freej2me fuse-libretro gambatte gearboy gearcoleco \
                  gearsystem genesis-plus-gx genesis-plus-gx-wide gpsp gw-libretro handy hatari jaxe lowresnx mame mame2000 mame2003-plus mame2010 mame2015 mame2016 meowpc98 mgba mojozork mupen64plus-nx \
                  neocd_libretro nestopia np2kai o2em opera parallel-n64 pcsx_rearmed picodrive pokemini potator ppsspp prboom prosystem puae puae2021 px68k quasi88 quicknes race same_cdi sameboy sameduck \
                  scummvm smsplus-gx snes9x snes9x2002 snes9x2005_plus snes9x2010 stella stella-2014 swanstation tgbdual tic-80 uae4arm uw8 uzem vbam vba-next vecx vice vircon32 virtualjaguar wasm4 xmil"

  LIBRETRO_CORES_EXTRA="beetle_snes bsnes bsnes2014_balanced bsnes2014_performance bsnes_mercury_balanced bsnes_mercury_performance mesen mesen-s"

  PKG_EMUS="${LIBRETRO_CORES}"

  if [[ "${DEVICE}" == "RG552" ]]; then
    PKG_EMUS+=" ${LIBRETRO_CORES_EXTRA}"
  fi

  PKG_EMUS+=" advancemame ppssppsa amiberry hatarisa openbor scummvmsa solarus hypseus-singe ecwolf lzdoom gzdoom raze drastic duckstation mupen64plussa piemu yabasanshiroSA"
fi

PKG_TOOLS="bash dialog grep wget ffmpeg libjpeg-turbo common-shaders glsl-shaders MC util-linux xmlstarlet sixaxis jslisten evtest mpv bluetool rs97-commander-sdl2 jslisten gnupg gzip valgrind strace gdb apitrace rg351p-js2xbox odroidgoa-utils rs97-commander-sdl2 textviewer 351files rclone jstest-sdl sdljoytest evdev-joystick gptokeyb"
PKG_RETROPIE_DEP="pyudev six git dbus-python coreutils"
PKG_DEPENDS_TARGET+=" ${PKG_TOOLS} ${PKG_RETROPIE_DEP} ${PKG_EMUS} ports"

if [[ "${DEVICE}" == "RG552" ]]; then
  PKG_DEPENDS_TARGET+=" webui"
fi

make_target() {
  :
}

makeinstall_target() {
  ## Remove libretro cores from unsupported devices
  if [[ ! ${DEVICE} == "RG552" ]]; then
    mkdir -p ${INSTALL}/usr/config/emulationstation
    cp -f $(get_build_dir emulationstation)/.install_pkg/usr/config/emulationstation/es_systems.cfg ${INSTALL}/usr/config/emulationstation/es_systems.cfg
    for CORE in ${LIBRETRO_CORES_EXTRA}; do
      sed -i "s|<core>$CORE</core>||g" ${INSTALL}/usr/config/emulationstation/es_systems.cfg
      sed -i '/^[[:space:]]*$/d' ${INSTALL}/usr/config/emulationstation/es_systems.cfg
    done
  fi

  mkdir -p ${INSTALL}/usr/config/SDL-GameControllerDB
  cp ${PKG_DIR}/SDL_GameControllerDB/gamecontrollerdb.txt ${INSTALL}/usr/config/SDL-GameControllerDB

  mkdir -p ${INSTALL}/usr/config/
  rsync -av ${PKG_DIR}/config/* ${INSTALL}/usr/config/

  if [ ! "${DEVICE}" == "RG351MP" ] && [ ! "${DEVICE}" == "RG351V" ]; then
    rm -rf ${INSTALL}/usr/config/distribution/modules/display_fix.sh
  fi

  ln -sf /storage/.config/distribution ${INSTALL}/distribution
  find ${INSTALL}/usr/config/distribution/ -type f -exec chmod o+x {} \;

  if [ "${DEVICE}" == "RG351P" ]; then
    cp ${INSTALL}/usr/config/distribution/configs/distribution.conf.351p ${INSTALL}/usr/config/distribution/configs/distribution.conf
  elif  [ "${DEVICE}" == "RG351V" ] || [ "${DEVICE}" == "RG351MP" ]; then
    cp ${INSTALL}/usr/config/distribution/configs/distribution.conf.351v ${INSTALL}/usr/config/distribution/configs/distribution.conf
  elif [ "${DEVICE}" == "RG552" ]; then
    cp ${INSTALL}/usr/config/distribution/configs/distribution.conf.552  ${INSTALL}/usr/config/distribution/configs/distribution.conf
  fi

  sed -i "s/system.hostname=AmberELEC/system.hostname=${DEVICE}/g" ${INSTALL}/usr/config/distribution/configs/distribution.conf

  echo "${LIBREELEC_VERSION}" > ${INSTALL}/usr/config/.OS_VERSION

  echo "${DEVICE}" > ${INSTALL}/usr/config/.OS_ARCH

  echo "$(date)" > ${INSTALL}/usr/config/.OS_BUILD_DATE

  mkdir -p ${INSTALL}/usr/bin/

  ## Compatibility links for ports
  ln -s /storage/roms ${INSTALL}/roms
  ln -s /roms/ports/PortMaster ${INSTALL}/portmaster
  #ln -sf /storage/roms/opt ${INSTALL}/opt

  mkdir -p ${INSTALL}/usr/lib
  ln -s /usr/lib32/ld-linux-armhf.so.3 ${INSTALL}/usr/lib/ld-linux-armhf.so.3

  mkdir -p ${INSTALL}/usr/share/retroarch-overlays
  if [ "${DEVICE}" == "RG351P" ]; then
    cp -r ${PKG_DIR}/overlay-p/* ${INSTALL}/usr/share/retroarch-overlays
  elif [ "${DEVICE}" == "RG351V" ] || [ "${DEVICE}" == "RG351MP" ]; then
    cp -r ${PKG_DIR}/overlay-v/* ${INSTALL}/usr/share/retroarch-overlays
  elif [ "${DEVICE}" == "RG552" ]; then
    cp -r ${PKG_DIR}/overlay-552/* ${INSTALL}/usr/share/retroarch-overlays
  fi

  mkdir -p ${INSTALL}/usr/share/libretro-database
     touch ${INSTALL}/usr/share/libretro-database/dummy

  # Move plymouth-lite bin to show splash screen
  cp $(get_build_dir plymouth-lite)/.install_init/usr/bin/ply-image ${INSTALL}/usr/bin

  mkdir -p ${INSTALL}/usr/config/splash

  find_file_path "splash/splash-*.png" && cp ${FOUND_PATH} ${INSTALL}/usr/config/splash

  mkdir -p ${INSTALL}/usr/share/bootloader
  if [ "${DEVICE}" == "RG351P" ]; then
    find_file_path "splash/splash-480.bmp" && cp ${FOUND_PATH} ${INSTALL}//usr/share/bootloader/logo.bmp
  elif [ "${DEVICE}" == "RG351V" ] || [ "${DEVICE}" == "RG351MP" ] ; then
    find_file_path "splash/splash-640.bmp" && cp ${FOUND_PATH} ${INSTALL}//usr/share/bootloader/logo.bmp
  elif [ "${DEVICE}" == "RG552" ]; then
    find_file_path "splash/splash-1920.bmp" && cp ${FOUND_PATH} ${INSTALL}//usr/share/bootloader/logo.bmp
  fi
}

post_install() {
# Remove unnecesary Retroarch Assets and overlays
  for i in FlatUX Automatic Systematic branding nuklear nxrgui pkg switch wallpapers zarch COPYING; do
    rm -rf "${INSTALL}/usr/share/retroarch-assets/${i}"
  done

  for i in automatic dot-art flatui neoactive pixel retroactive retrosystem systematic convert.sh NPMApng2PMApng.py; do
    rm -rf "${INSTALL}/usr/share/retroarch-assets/xmb/${i}"
  done

  mkdir -p ${INSTALL}/etc/retroarch-joypad-autoconfig
  cp -r ${PKG_DIR}/gamepads/* ${INSTALL}/etc/retroarch-joypad-autoconfig
  ln -sf amberelec.target ${INSTALL}/usr/lib/systemd/system/default.target
  enable_service amberelec-autostart.service
<<<<<<< HEAD
  enable_service lastgame.service
=======
  enable_service hotkey.service
>>>>>>> 8a1cfde0 (hotkey for poweroff)
  if [[ "${DEVICE}" == "RG552" ]]; then
    enable_service fan_control.service
  fi

  echo "" >${INSTALL}/etc/issue
  echo -e "\033[38;5;220m     _         _            \033[38;5;255m ___ _    ___ ___ " >>${INSTALL}/etc/issue
  echo -e "\033[38;5;220m    /_\  _ __ | |__  ___ _ _\033[38;5;255m| __| |  | __/ __|" >>${INSTALL}/etc/issue
  echo -e "\033[38;5;220m   / _ \| '  \| '_ \/ -_) '_\033[38;5;255m| _|| |__| _| (__ " >>${INSTALL}/etc/issue
  echo -e "\033[38;5;220m  /_/ \_\_|_|_|_.__/\___|_| \033[38;5;255m|___|____|___\___|" >>${INSTALL}/etc/issue
  echo -e "\033[0m" >>${INSTALL}/etc/issue
  echo "" >>${INSTALL}/etc/issue

  ln -s /etc/issue ${INSTALL}/etc/motd

  cp ${PKG_DIR}/sources/amberelec.dialogrc ${INSTALL}/etc
  cp ${PKG_DIR}/sources/autostart.sh ${INSTALL}/usr/bin
  cp ${PKG_DIR}/sources/shutdown.sh ${INSTALL}/usr/bin
  cp ${PKG_DIR}/sources/pico-8.sh ${INSTALL}/usr/bin
  cp ${PKG_DIR}/sources/pico-8.sh "${INSTALL}/usr/config/distribution/modules/Start Pico-8.sh"
  cp ${PKG_DIR}/sources/scripts/* ${INSTALL}/usr/bin

  rm -f ${INSTALL}/usr/bin/{sh,bash,busybox,sort}
  cp $(get_build_dir busybox)/.install_pkg/usr/bin/busybox ${INSTALL}/usr/bin
  cp $(get_build_dir bash)/.install_pkg/usr/bin/bash ${INSTALL}/usr/bin
  cp $(get_build_dir coreutils)/.install_pkg/usr/bin/sort ${INSTALL}/usr/bin

  ln -sf bash ${INSTALL}/usr/bin/sh
  mkdir -p ${INSTALL}/etc
  echo "/usr/bin/bash" >>${INSTALL}/etc/shells
  echo "/usr/bin/sh" >>${INSTALL}/etc/shells

  echo "chmod 4755 ${INSTALL}/usr/bin/bash" >> ${FAKEROOT_SCRIPT}
  echo "chmod 4755 ${INSTALL}/usr/bin/busybox" >> ${FAKEROOT_SCRIPT}
  find ${INSTALL}/usr/ -type f -iname "*.sh" -exec chmod +x {} \;
  find ${INSTALL}/usr/bin -type f -exec chmod +x {} \;
}
