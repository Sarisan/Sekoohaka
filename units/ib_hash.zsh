# Copyright (C) 2024-2026 Maria Lisina
# Copyright (C) 2024-2026 Danil Lisin
# SPDX-License-Identifier: Apache-2.0

rm -f "${ib_post}"
ib_mode="p"

source "${units}/ib_config.zsh"
source "${units}/ib_authconfig.zsh"

ib_query="md5:${ib_post_md5}"

ib_hash="$(sha1sum <<< "${user_id}${ib_board}${ib_query}" | cut -d ' ' -f 1)"
ib_file="${cache}/${ib_hash}.json"

until mkdir "${cache}/${ib_hash}.lock"
do
    sleep 1
done

source "${units}/ib_file.zsh"

if [[ -n "${output_text}" ]]
then
    rmdir "${cache}/${ib_hash}.lock"
    exit
fi

if [[ -z "${output_text}" ]]
then
    ib_id="$(jq -r ".[0].${ib_iid}" "${ib_file}")"

    if ! [[ -f "${ib_sample}" ]]
    then
        ib_file_size="$(jq -r ".[0].${ib_isize}" "${ib_file}")"
        ib_file_url="$(jq -r ".[0].${ib_ifile}" "${ib_file}")"
        ib_sample_url="$(jq -r ".[0].${ib_isample}" "${ib_file}")"
        ib_preview_url="$(jq -r ".[0].${ib_ipreview}" "${ib_file}")"

        source "${units}/ib_meta.zsh"

        printf "%s\n" "${ib_sample_url}" > "${ib_sample}"
    fi

    printf "%s\n" "${ib_id}" > "${ib_post}"
fi

rmdir "${cache}/${ib_hash}.lock"
