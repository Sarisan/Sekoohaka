# Copyright (C) 2024-2025 Maria Lisina
# Copyright (C) 2024-2025 Danil Lisin
# SPDX-License-Identifier: Apache-2.0

ib_mode="p"

. "${units}/ib_config.zsh"
. "${units}/ib_authconfig.zsh"

ib_query="md5:${ib_post_md5}"

ib_hash="$(printf "%s%s%s" "${user_id}" "${ib_board}" "${ib_post_md5}" | enhash)"
. "${units}/ib_file.zsh"

if [[ -z "${output_text}" ]]
then
    ib_id="$(jq -r ".${ib_iarray}[0].${ib_iid}" "${ib_file}")"
    printf "<b>%s ID:</b> <code>%s</code>\n" "${ib_name}" "${ib_id}" >> "${ib_posts}"
fi
