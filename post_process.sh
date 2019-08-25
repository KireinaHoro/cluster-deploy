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

check_data_disk() {
    for disk in "${DATA_DISKS[@]}"; do
        [ -b "${disk}" ] || die "Disk ${disk} specified in \$DATA_DISKS not found."
    done

    case ${RAID_SCHEME} in
        none)
            (( ${#DATA_DISKS[@]} == 0 )) || die "\"none\" specified in \$RAID_SCHEME; no disks should be listed in \$DATA_DISKS."
            info "Not creating data storage"
            ;;

        stripe)
            (( ${#DATA_DISKS[@]} >= 1 )) || die "At least 1 disk needed for \"stripe\" in \$RAID_SCHEME."
            [ -n "${POOL_NAME}" ] || die "\$POOL_NAME required when \$RAID_SCHEME != none."
            info "Will create stripe ZFS pool with ${DATA_DISKS[@]}"
            ;;

        raidz1)
            (( ${#DATA_DISKS[@]} >= 3 )) || die "At least 3 disk needed for \"raidz1\" in \$RAID_SCHEME."
            [ -n "${POOL_NAME}" ] || die "\$POOL_NAME required when \$RAID_SCHEME != none."
            info "Will create raidz1 ZFS pool with ${DATA_DISKS[@]}"
            ;;

        raidz2)
            (( ${#DATA_DISKS[@]} >= 5 )) || die "At least 5 disk needed for \"raidz2\" in \$RAID_SCHEME."
            [ -n "${POOL_NAME}" ] || die "\$POOL_NAME required when \$RAID_SCHEME != none."
            info "Will create raidz2 ZFS pool with ${DATA_DISKS[@]}"
            ;;

        raidz3)
            (( ${#DATA_DISKS[@]} >= 8 )) || die "At least 8 disk needed for \"raidz3\" in \$RAID_SCHEME."
            [ -n "${POOL_NAME}" ] || die "\$POOL_NAME required when \$RAID_SCHEME != none."
            info "Will create raidz3 ZFS pool with ${DATA_DISKS[@]}"
            ;;

        *)
            die "Unknown \$RAID_SCHEME \"${RAID_SCHEME}\" specified."
    esac
}

deploy_into_target() {
    local script_dir="$(readlink -f "$(dirname "${BASH_SOURCE[0]}")")"
    TARGET_SCRIPT_DIR="${ROOT_MNT_PATH}/usr/local/cluster-deploy/"
    info "Copying ${script_dir}/* to ${TARGET_SCRIPT_DIR}..."
    assert mkdir -p "${TARGET_SCRIPT_DIR}"
    assert cp -Rv ${script_dir}/* ${TARGET_SCRIPT_DIR}
}

do_chroot_mounts() {
    info "Mounting pseudo filesystems for chroot in ${ROOT_MNT_PATH}..."
    for pfs in proc dev sys; do
        assert mount --rbind /${pfs} ${ROOT_MNT_PATH}/${pfs}
        assert mount --make-rslave ${ROOT_MNT_PATH}/${pfs}
    done
}

do_create_pool() {
    case ${RAID_SCHEME} in
        none)
            info "Not creating ZFS pool."
            ;;

        stripe)
            info "Creating stripe ZFS pool..."
            assert zpool create -f "${POOL_NAME}" ${DATA_DISKS[@]} ${ZPOOL_OPTIONS}
            ;;

        *)
            info "Creating ${RAID_SCHEME} ZFS pool..."
            assert zpool create -f "${POOL_NAME}" ${RAID_SCHEME} ${DATA_DISKS[@]} ${ZPOOL_OPTIONS}
            ;;
    esac

    assert zpool status
}

configure_target() {
    deploy_into_target
    do_chroot_mounts
    assert chroot "${ROOT_MNT_PATH}" /usr/local/cluster-deploy/chroot_tasks.sh
    do_create_pool
    # networking (?)
}

reboot_new_environment() {
    warn "Rebooting in ${REBOOT_TIMEOUT} seconds.  Select \"${TARGET}\" in UEFI settings to boot into the new deploy."
    sleep ${REBOOT_TIMEOUT}
    assert reboot
}
