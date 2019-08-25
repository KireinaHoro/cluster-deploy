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

set -e

cd /usr/local/cluster-deploy
source util.sh
source prepare_partition.sh

export PATH="/sbin:/bin:/usr/sbin:/usr/bin"

check_config
export_paths

# Set hostname.
info "Setting hostname as ${FQDN}..."
echo "${FQDN}" > /etc/hostname

# Regenerate machine-id.
info "Generating /etc/machine-id..."
assert rm -f /etc/machine-id
assert systemd-machine-id-setup
info "New machine-id: $(assert cat /etc/machine-id)"

# Set timezone.
info "Setting timezone to ${TIMEZONE}..."
assert ln -sf ../usr/share/zoneinfo/${TIMEZONE} /etc/localtime

# Create fstab.
esp_uuid=$(get_uuid "${ESP_PATH}")
boot_uuid=$(get_uuid "${BOOT_PATH}")
info "EFI System Partition (${ESP_PATH}) UUID: ${esp_uuid}"
info "Boot partition (${BOOT_PATH}) UUID: ${boot_uuid}"
cat > /etc/fstab << _EOF_
/dev/${VG}/root / xfs defaults 0 0
UUID=${boot_uuid} /boot xfs defaults 0 0
UUID=${esp_uuid} /boot/efi vfat umask=0077,shortname=winnt 0 0
tmpfs /tmp tmpfs defaults 0 0
_EOF_

# Set root shadow.
info "Setting root password..."
echo "root:${ROOT_SHADOW}" | assert chpasswd -e

# Add additional admins.
info "Adding administrators..."
for user in "${WHEEL_USERS[@]}"; do
    username=$(echo "${user}" | cut -d':' -f1)
    if getent passwd ${username} >/dev/null; then
        warn "User \"${username}\" already exists; overriding shadow only"
    else
        info "Creating admin \"${username}\"..."
        assert useradd -m -G wheel "${username}"
    fi
    echo "${user}" | assert chpasswd -e
done

# Add additional users.
if (( ${#NORMAL_USERS[@]} )); then
    info "Adding normal users..."
    for user in "${NORMAL_USERS[@]}"; do
        username=$(echo "${user}" | cut -d':' -f1)
        if getent passwd ${username} >/dev/null; then
            warn "User \"${username}\" already exists; overriding shadow only"
        else
            info "Creating user \"${username}\"..."
            assert useradd -m "${username}"
        fi
        echo "${user}" | assert chpasswd -e
    done
fi

# Register first-boot hooks.
warn First-boot hooks not implemented

