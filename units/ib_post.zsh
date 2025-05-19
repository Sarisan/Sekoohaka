# Copyright (C) 2024-2025 Maria Lisina
# Copyright (C) 2024-2025 Danil Lisin
# SPDX-License-Identifier: Apache-2.0

ib_id="$(jq -r ".${ib_iarray}[0].${ib_iid}" "${ib_file}")"
ib_created_at="$(jq -r ".${ib_iarray}[${array_count}].${ib_icreated}" "${ib_file}")"
ib_file_size="$(jq -r ".${ib_iarray}[0].${ib_isize}" "${ib_file}")"
ib_file_url="$(jq -r ".${ib_iarray}[0].${ib_ifile}" "${ib_file}")"
ib_rating="$(jq -r ".${ib_iarray}[0].${ib_irating}" "${ib_file}")"
ib_parent_id="$(jq -r ".${ib_iarray}[0].${ib_iparent}" "${ib_file}")"
ib_has_children="$(jq -r ".${ib_iarray}[0].${ib_ichildren}" "${ib_file}")"
ib_md5="$(jq -r ".${ib_iarray}[0].${ib_imd5}" "${ib_file}")"
ib_source="$(jq -r ".${ib_iarray}[0].${ib_isource}" "${ib_file}" | htmlescape)"
ib_tags=($(jq -r ".${ib_iarray}[0].${ib_itags}" "${ib_file}"))

. "${units}/ib_date.zsh"
. "${units}/ib_size.zsh"
. "${units}/ib_meta.zsh"

output_text="$(printf "<b>%s</b>\n<b>ID:</b> <code>%s</code>" "${ib_name}" "${ib_id}")"

if [[ -n "${ib_date_text}" ]]
then
    output_text="$(printf "%s\n<b>Date:</b> <code>%s</code>" "${output_text}" "${ib_date_text}")"
fi

if [[ -n "${ib_resolution_text}" ]]
then
    output_text="$(printf "%s\n<b>Resolution:</b> %s" "${output_text}" "${ib_resolution_text}")"
fi

if [[ -n "${ib_size_text}" ]]
then
    output_text="$(printf "%s\n<b>Size:</b> %s" "${output_text}" "${ib_size_text}")"
fi

if [[ -n "${ib_type_text}" ]]
then
    output_text="$(printf "%s\n<b>Type:</b> %s" "${output_text}" "${ib_type_text}")"
fi

if [[ -n "${ib_rating}" && "${ib_rating}" != "null" ]]
then
    while [[ ${#ib_ratings} -ge 2 ]]
    do
        if [[ "${ib_rating}" = "${ib_ratings[1]}" ]]
        then
            output_text="$(printf "%s\n<b>Rating:</b> <code>%s</code>" "${output_text}" "${ib_ratings[2]}")"
            break
        else
            ib_ratings=(${ib_ratings[@]:2})
        fi
    done
fi

if [[ -n "${ib_parent_id}" && "${ib_parent_id}" != "null" && "${ib_parent_id}" != "0" ]]
then
    output_text="$(printf "%s\n<b>Parent ID:</b> <code>%s</code>" "${output_text}" "${ib_parent_id}")"
fi

if [[ "${ib_has_children}" = "true" ]]
then
    output_text="$(printf "%s\n<b>Has children:</b> yes" "${output_text}")"
fi

if [[ -n "${ib_md5}" && "${ib_md5}" != "null" ]]
then
    output_text="$(printf "%s\n<b>MD5:</b> <code>%s</code>" "${output_text}" "${ib_md5}")"
fi

if [[ -n "${ib_source}" && "${ib_source}" != "null" ]]
then
    if echo "${ib_source}" | grep -q -e "pixiv" -e "pximg"
    then
        ib_source="https://www.pixiv.net/artworks/$(printf "%s" "${ib_source##*/}" | cut -d '_' -f 1)"
    fi

    if [[ ${#ib_source} -le 2048 ]]
    then
        output_text="$(printf "%s\n<b>Source:</b> %s" "${output_text}" "${ib_source}")"
    fi
fi
