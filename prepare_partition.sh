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

source util.sh

check_target() {
    if [ ! -b "${TARGET}" ]; then
        die "Target disk ${TARGET} not found.  Check if the specified \
path is present and that udev is running."
    fi
    [[ "${TARGET}" == /dev/disk/by-path/* ]] || die "Please use by-path name for target disk.  Current value: ${TARGET}"

    info "Target disk: ${TARGET}"
}

export_paths() {
    ESP_PATH="${TARGET}-part1"
    BOOT_PATH="${TARGET}-part2"
    PV_PATH="${TARGET}-part3"
    ROOT_PATH="/dev/${VG}/root"
    ROOT_MNT_PATH="/mnt/deploy/root"
    BOOT_MNT_PATH="${ROOT_MNT_PATH}/boot"
}

prepare_partition() {
    info "Creating new GPT on ${TARGET}..."
    warn "All data on ${TARGET} will be lost!"

    assert sgdisk -og ${TARGET} >/dev/null
    assert sgdisk -n 1:2048:411647 -c 1:"EFI System Partition" -t 1:ef00 ${TARGET} >/dev/null
    assert sgdisk -n 2:411648:2508799 -c 2:"Linux /boot" -t 2:0700 ${TARGET} >/dev/null
    local disk_end="$(assert sgdisk -E ${TARGET})"
    assert sgdisk -n 3:2508800:${disk_end} -c 3:"Linux LVM" -t 3:8e00 ${TARGET} >/dev/null
    info "New partition table for ${TARGET}:"
    assert sgdisk -p ${TARGET}
    info "Triggering udev event update..."
    assert udevadm trigger

    info "Creating LVM PV on ${PV_PATH}..."
    assert pvcreate -ff -y "${PV_PATH}"
    assert pvdisplay "${PV_PATH}"

    info "Creating LVM VG with name ${VG}..."
    assert vgcreate -y "${VG}" "${PV_PATH}"
    assert vgdisplay "${VG}"

    info "Creating LVM LV for root..."
    assert lvcreate -y -l+100%FREE -n root "${VG}"
    assert lvdisplay "${VG}/root"

    info "Creating XFS for /boot on ${BOOT_PATH}..."
    assert mkfs.xfs -f "${BOOT_PATH}"

    info "Creating XFS for / on ${ROOT_PATH}..."
    assert mkfs.xfs -f "${ROOT_PATH}"

    info "Mounting root at ${ROOT_MNT_PATH}..."
    assert mkdir -p "${ROOT_MNT_PATH}"
    assert mount "${ROOT_PATH}" "${ROOT_MNT_PATH}"

    info "Mounting boot at ${BOOT_MNT_PATH}..."
    assert mkdir -p "${BOOT_MNT_PATH}"
    assert mount "${BOOT_PATH}" "${BOOT_MNT_PATH}"

    info "Partition preparation finished"
}

