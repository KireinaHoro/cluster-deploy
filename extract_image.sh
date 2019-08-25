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

check_image() {
    local images=(esp.img.gz boot.xfsdump.gz root.xfsdump.gz)
    if [ -d "${IMAGE_ROOT}" ]; then
        pushd "${IMAGE_ROOT}" &>/dev/null
        for img in "${images[@]}"; do
            [ -f "${img}" ] || die "Required image ${img} not found in ${IMAGE_ROOT}."
        done
        popd &>/dev/null
    else
        die "${IMAGE_ROOT} is not a valid directory."
    fi

    ESP_IMG="${IMAGE_ROOT}/esp.img.gz"
    BOOT_IMG="${IMAGE_ROOT}/boot.xfsdump.gz"
    ROOT_IMG="${IMAGE_ROOT}/root.xfsdump.gz"
}

unpack_images() {
    info "Unpacking ESP image to ${ESP_PATH}..."   
    assert gzip -cd "${ESP_IMG}" | assert dd of="${ESP_PATH}" status=progress bs=64K

    info "Unpacking boot xfsdump to ${BOOT_MNT_PATH}..."
    assert gzip -cd "${BOOT_IMG}" | assert xfsrestore - "${BOOT_MNT_PATH}"

    info "Mounting ESP to ${BOOT_MNT_PATH}/efi..."
    assert mount "${ESP_PATH}" "${BOOT_MNT_PATH}/efi"

    info "Unpacking root xfsdump to ${ROOT_MNT_PATH}..."
    assert gzip -cd "${ROOT_IMG}" | assert xfsrestore - "${ROOT_MNT_PATH}"

    info "Unpacking images finished"
}
