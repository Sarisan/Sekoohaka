# Copyright (C) 2024-2025 Maria Lisina
# Copyright (C) 2024-2025 Danil Lisin
# SPDX-License-Identifier: Apache-2.0

ib_mode="p"

. "${units}/ib_config.zsh"
. "${units}/ib_authconfig.zsh"

if [[ -z "${ib_data_url}" ]]
then
    exit 0
fi

ib_query="md5:${ib_post_md5}"

ib_hash="$(sha1sum <<< "${user_id}${ib_board}${ib_query}" | cut -d ' ' -f 1)"
. "${units}/ib_file.zsh"

if [[ -z "${output_text}" ]]
then
    ib_id="$(jq -r ".${ib_iarray}[0].${ib_iid}" "${ib_file}")"
    printf "%s\n" "${ib_id}" > "${ib_post_id}"
fi
