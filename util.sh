#!/usr/bin/env bash
#
# Copyright 2019 Pengcheng Xu <i@jsteward.moe>
# 
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
#     https://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

info() {
    echo "[INFO ] $@"
}

warn() {
    echo -e "\e[33m[WARN ] $@\e[39m" >&2
}

die() {
    echo -e "\e[31m[FATAL] $@\e[39m" >&2
    exit 1
}

assert() {
    "$@" || die "Command \"$@\" failed with return status $?"
}

greetings() {
    warn "Deploying cluster node for ${VENDOR}"
    warn "Target host: ${FQDN}"
}

check_config() {
    if [ ! -f "settings.sh" ]; then
        die "settings.sh missing."
    fi
    source settings.sh
    for var in IMAGE_ROOT HOSTNAME DOMAIN TARGET VG RAID_SCHEME TIMEZONE ROOT_SHADOW WHEEL_USERS REBOOT_TIMEOUT; do
        [ -n "${!var+x}" ] || die "Required config \$${var} not found in settings.sh."
    done

    # define FQDN for later use.
    FQDN="${HOSTNAME}.${DOMAIN}"
}

check_commands() {
    local commands=(cp sgdisk pvcreate pvdisplay vgcreate vgdisplay lvcreate lvdisplay mkfs.xfs udevadm mount gzip dd sed xfsrestore chroot zpool)
    for cmd in ${commands[@]}; do
        command -v ${cmd} &>/dev/null || die "Required command ${cmd} not found."
    done
}

get_uuid() {
    local real_disk=$(readlink -f $1)
    blkid | sed -n "s@^${real_disk}:.* UUID=\"\([^ ]*\)\".*\$@\1@p"
}

