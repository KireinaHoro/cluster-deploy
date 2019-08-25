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

#============================================================================
# This is the configuration file for node deployment.  Read every configura-
# tion item and fill in / change information accordingly.
#============================================================================

# Vendor for this deployment.
VENDOR="Contoso Ltd"

# Directory that contains the partition images.
# The following files are required at present:
# - esp.img.gz: raw EFI System Partition image, GZip'ed
#   mountpoint: /boot/efi
# - boot.xfsdump.gz: boot xfsdump, GZip'ed
#   mountpoint: /boot
# - root.xfsdump.gz: root xfsdump, GZip'ed
#   mountpoint: /
IMAGE_ROOT="../image"

# (short) hostname for the deployed host.
# The full hostname will be the FQDN (host.domain).
HOSTNAME="demo"

# Domain that the host belongs to.
# The full hostname will be the FQDN (host.domain).
DOMAIN="contoso.com"

# Target block device path for deployment.
# Use udev by-path or by-id paths (/dev/disk/by-path/*).
#TARGET="/dev/disk/by-path/pci-0000:00:11.5-ata-3.0"

# LVM VG name on target.
VG="node"

# Data storage configuration for the node.  
# The following configurations are available at present:
# - none: no data volume
# - stripe: no redundancy
# - raidz1: single redundancy
# - raidz2: double redundancy
# - raidz3: triple redundancy
RAID_SCHEME="raidz1"

# ZFS pool name.
POOL_NAME="tank"

# Disk list for data storage.  These will be passed to zpool
# create command; use proper names (e.g. by-path, by-id); avoid
# plain device names (e.g. /dev/sda) as they are prone to change
# on device relocation.
#DATA_DISKS=(
#/dev/disk/by-path/pci-0000:00:11.5-ata-4.0
#/dev/disk/by-path/pci-0000:00:11.5-ata-5.0
#/dev/disk/by-path/pci-0000:00:11.5-ata-6.0
#)

# Optional zpool options to add to "zpool create".
ZPOOL_OPTIONS=""

# Timezone for the target.
# /usr/share/zoneinfo/${TIMEZONE} should be present.
TIMEZONE="Asia/Shanghai"

# Root password, in shadow format.
# The following is for "defaultpassword" (without quotes) with a random salt.
ROOT_SHADOW='$6$BpQgnLrExfzaDUu0$Jyrfiuu5gJ6CFtTu0q8K90020a.ovl.yqu141PtH7KeixnxI.wI7VM69rTpOI5FtAzbYdqpzc.HizfEN5RJXK.'

# Administrators to be added to the target.  At least one required.
# Users denoted here will be added to the "wheel" group.
# The following denotes a single "admin" user with "defaultadminpassword" as password.
# Add more admins by adding more "user:shadow" lines.
WHEEL_USERS=(
'admin:$6$yJHv0ncuhVb5MBfa$77JnZyKEBc8ndhUMTZJ0MKzzwkDJ2NWXwn2billsbgAVBNgFPasL6YvllBBa7eDzP5rZ7dm3WWxMtdmd3XccD.'
)

# Non-admin users to be added to the target.  Same syntax as admin specification.
NORMAL_USERS=(
)

# Reboot timeout in seconds.
REBOOT_TIMEOUT="10"
