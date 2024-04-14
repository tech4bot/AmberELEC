# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2024-present tech4bot (https://github.com/tech4bot)
# Copyright (C) 2024-present AmberELEC (https://github.com/AmberELEC)

PKG_NAME="filebrowser"
PKG_VERSION="2.27.0"
PKG_LICENSE="Apache License 2.0"
PKG_SHA256="fe68b8f95f9eba2069fe337c7f062bab6da5673f4153c0716a0834caebf261a6"
PKG_SITE="https://filebrowser.org/"
PKG_URL="https://github.com/filebrowser/filebrowser/releases/download/v${PKG_VERSION}/linux-arm64-filebrowser.tar.gz"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="filebrowser provides a file managing interface within a specified directory and it can be used to upload, delete, preview, rename and edit your files. It allows the creation of multiple users and each user can have its own directory. It can be used as a standalone app."
PKG_TOOLCHAIN="manual"

unpack() {
  mkdir -p ${PKG_BUILD}
  tar -xf ${SOURCES}/${PKG_NAME}/${PKG_NAME}-${PKG_VERSION}.tar.gz -C ${PKG_BUILD}
}

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/bin
  cp filebrowser ${INSTALL}/usr/bin
  cp -f ${PKG_DIR}/sources/filebrowser.sh ${INSTALL}/usr/bin
  mkdir -p ${INSTALL}/usr/config/distribution/configs/filebrowser
  cp -f ${PKG_DIR}/sources/filebrowser.json ${INSTALL}/usr/config/distribution/configs/filebrowser
  cp -f ${PKG_DIR}/sources/users.json ${INSTALL}/usr/config/distribution/configs/filebrowser
  chmod 0755 ${INSTALL}/usr/bin/*
}