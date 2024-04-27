# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2022-present AmberELEC (https://github.com/AmberELEC)

PKG_NAME="rkbin"

if [[ "${DEVICE}" =~ RG351 ]]; then
	PKG_VERSION="788973610ade36c127a26d534a147b41df553b29"
elif [[ "${DEVICE}" =~ RG552 ]]; then
	PKG_VERSION="fc44f9401c127affb2a879c1e90fa89ddab505f6"
fi

PKG_ARCH="arm aarch64"
PKG_LICENSE="nonfree"
PKG_SITE="https://github.com/tech4bot/rkbin"
PKG_URL="https://github.com/tech4bot/rkbin/archive/${PKG_VERSION}.tar.gz"
PKG_LONGDESC="rkbin: Rockchip Firmware and Tool Binaries"
PKG_TOOLCHAIN="manual"
