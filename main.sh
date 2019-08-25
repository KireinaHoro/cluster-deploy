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

source util.sh
source prepare_partition.sh
source extract_image.sh
source post_process.sh

# Perform necessary checks.
check_config
greetings

check_commands
check_target
check_data_disk
check_image

# Set up path variables.
export_paths

# Prepare the partitions on target disk.
prepare_partition

# Unpack the images onto the target disk.
unpack_images

# Do necessary configuration.
# Note: this stage sets up first-boot hooks.
configure_target

# Set boot order, reboot into new environment.
reboot_new_environment

