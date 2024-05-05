# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2024 AmberELEC (https://github.com/AmberELEC)

PKG_NAME="es-theme-art-book-next"
PKG_VERSION="284ab87135ba0fdae3d5e44e9d485a5f22ed10ec"
PKG_ARCH="any"
PKG_LICENSE="CUSTOM"
PKG_SITE="https://github.com/AmberELEC/art-book-next-amberelec"
PKG_URL="${PKG_SITE}.git"
PKG_SHORTDESC="ArtBook Next"
PKG_LONGDESC="Art Book Next - AmberELEC default theme"
PKG_TOOLCHAIN="manual"

makeinstall_target() {
    mkdir -p ${INSTALL}/usr/config/emulationstation/themes/${PKG_NAME}
    cp -rf * ${INSTALL}/usr/config/emulationstation/themes/${PKG_NAME}
}
