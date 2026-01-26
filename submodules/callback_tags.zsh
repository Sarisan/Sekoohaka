# Copyright (C) 2024-2026 Maria Lisina
# Copyright (C) 2024-2026 Danil Lisin
# SPDX-License-Identifier: Apache-2.0

ib_lock=0
source "${units}/ib_common.zsh"

if [[ -n "${notification_text}" ]]
then
    return
fi

ib_hash="$(sha1sum <<< "${user_id}${ib_board}${ib_query}" | cut -d ' ' -f 1)"
ib_file="${cache}/${ib_hash}.json"

until mkdir "${cache}/${ib_hash}.lock"
do
    sleep 1
done

source "${units}/ib_file.zsh"

if [[ -n "${notification_text}" ]]
then
    rmdir "${cache}/${ib_hash}.lock"
    return
fi

ib_file_size="$(jq -r ".${ib_iarray}[0].${ib_isize}" "${ib_file}")"
ib_file_url="$(jq -r ".${ib_iarray}[0].${ib_ifile}" "${ib_file}")"
ib_sample_url="$(jq -r ".${ib_iarray}[0].${ib_isample}" "${ib_file}")"
ib_preview_url="$(jq -r ".${ib_iarray}[0].${ib_ipreview}" "${ib_file}")"
ib_width="$(jq -r ".${ib_iarray}[0].${ib_iwidth}" "${ib_file}")"
ib_height="$(jq -r ".${ib_iarray}[0].${ib_iheight}" "${ib_file}")"
ib_tags=($(jq -r ".${ib_iarray}[0].${ib_itags}" "${ib_file}"))
ib_groups_offset=${1:-0}
ib_tags_offset=${1:-0}

source "${units}/ib_size.zsh"
source "${units}/ib_meta.zsh"

if [[ -z "${ib_tags}" || "${ib_tags}" == "null" ]]
then
    notification_text="Failed to get tags"

    rmdir "${cache}/${ib_hash}.lock"
    return
fi

while [[ ${#ib_groups} -ge 2 ]]
do
    ib_group_tags=($(jq -r ".${ib_iarray}[0].${ib_groups[1]}" "${ib_file}" | htmlescape))
    ib_group_name="${ib_groups[2]}"

    if [[ -z "${ib_group_tags}" || "${ib_group_tags}" == "null" ]]
    then
        shift 2 ib_groups
        continue
    fi

    if [[ ${#ib_group_tags} -gt ${ib_groups_offset} ]]
    then
        shift ${ib_groups_offset} ib_group_tags
        ib_groups_offset=0
    else
        ib_groups_offset=$((ib_groups_offset - $#ib_group_tags))
        shift 2 ib_groups
        continue
    fi

    ib_group_text="$(printf "%s\n<b>%s:</b>" "${output_text}" "${ib_group_name}")"

    while [[ ${#ib_group_tags} -gt 0 ]]
    do
        ib_tag="<code>${ib_group_tags[1]}</code>"

        if [[ $(($#ib_group_text + $#ib_tag)) -gt 2048 ]]
        then
            break 2
        fi

        ib_group_text="${ib_group_text} ${ib_tag}"
        ib_tags_count=$((ib_tags_count + 1))

        output_text="${ib_group_text}"
        shift 1 ib_group_tags
    done

    shift 2 ib_groups
done

if [[ -z "${output_text}" ]]
then
    notification_text="No tags found"

    rmdir "${cache}/${ib_hash}.lock"
    return
fi

link_preview_options="$(
    jq --null-input --compact-output \
        --arg url "${ib_sample_url}" \
        '{"url": $url, "prefer_small_media": true, "show_above_text": true}'
)"

keyboard_text1="Back"
keyboard_data1="post ${ib_board} ${ib_post_id}"

reply_markup="$(
    jq --null-input --compact-output \
        --arg text1 "${keyboard_text1}" \
        --arg data1 "${keyboard_data1}" \
        '{"inline_keyboard": [[{"text": $text1, "callback_data": $data1}]]}'
)"

if [[ ${ib_tags_offset} -gt 0 ]]
then
    keyboard_text1="Over"
    keyboard_data1="tags ${ib_board} ${ib_post_id}"

    reply_markup="$(
        jq --compact-output \
            --arg text1 "${keyboard_text1}" \
            --arg data1 "${keyboard_data1}" \
            '.inline_keyboard[0] += [{"text": $text1, "callback_data": $data1}]' \
        <<< "${reply_markup}"
    )"
fi

if [[ $(($#ib_tags - ib_tags_offset - ib_tags_count)) -gt 0 ]]
then
    keyboard_text1="Next"
    keyboard_data1="tags ${ib_board} ${ib_post_id} $((ib_tags_offset + ib_tags_count))"

    reply_markup="$(
        jq --compact-output \
            --arg text1 "${keyboard_text1}" \
            --arg data1 "${keyboard_data1}" \
            '.inline_keyboard[0] += [{"text": $text1, "callback_data": $data1}]' \
        <<< "${reply_markup}"
    )"
fi

rmdir "${cache}/${ib_hash}.lock"
