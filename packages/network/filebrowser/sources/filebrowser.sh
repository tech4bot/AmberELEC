#!/bin/sh

# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2024-present tech4bot (https://github.com/tech4bot)
# Copyright (C) 2024-present AmberELEC (https://github.com/AmberELEC)

. /etc/profile

if ! test -f /storage/.config/filebrowser.json; then
  cp -f /usr/config/distribution/configs/filebrowser/filebrowser.json /storage/.config/filebrowser.json
  /usr/bin/filebrowser config init -d /storage/.config/filebrowser.db
  /usr/bin/filebrowser config import /storage/.config/filebrowser.json -d /storage/.config/filebrowser.db
  /usr/bin/filebrowser users import /usr/config/distribution/configs/filebrowser/users.json -d /storage/.config/filebrowser.db
fi

filebrowser -c /storage/.config/filebrowser.json -d /storage/.config/filebrowser.db &
