# Copyright (C) 2024-2025 Maria Lisina
# Copyright (C) 2024-2025 Danil Lisin
# SPDX-License-Identifier: Apache-2.0

ib_lock=0
. "${units}/ib_common.zsh"

if [[ -n "${notification_text}" ]]
then
    return 0
fi

ib_created_at="$(jq -r ".${ib_iarray}[${array_count}].${ib_icreated}" "${ib_file}")"
ib_file_size="$(jq -r ".${ib_iarray}[0].${ib_isize}" "${ib_file}")"
ib_file_url="$(jq -r ".${ib_iarray}[0].${ib_ifile}" "${ib_file}")"
ib_tags=($(jq -r ".${ib_iarray}[0].${ib_itags}" "${ib_file}" | htmlescape))
ib_groups_offset=${1:-0}
ib_tags_offset=${1:-0}
ib_tags_count=0

. "${units}/ib_size.zsh"
. "${units}/ib_meta.zsh"

if [[ -z "${ib_tags}" || "${ib_tags}" = "null" ]]
then
    notification_text="Failed to get tags"
    return 0
fi

while [[ ${#ib_groups} -ge 2 ]]
do
    ib_group_tags=($(jq -r ".${ib_iarray}[0].${ib_groups[1]}" "${ib_file}" | htmlescape))
    ib_group_name="${ib_groups[2]}"

    if [[ -n "${ib_group_tags}" && "${ib_group_tags}" != "null" ]]
    then
        if [[ ${#ib_group_tags} -gt ${ib_groups_offset} ]]
        then
            ib_group_tags=(${ib_group_tags[@]:${ib_groups_offset}})
            ib_groups_offset=0
        else
            ib_groups_offset=$((ib_groups_offset - $#ib_group_tags))
            ib_groups=(${ib_groups[@]:2})
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
            ib_group_tags=(${ib_group_tags[@]:1})
        done
    fi

    ib_groups=(${ib_groups[@]:2})
done

if [[ -z "${output_text}" ]]
then
    notification_text="No tags found"
    return 0
fi

link_preview_options="$(jq --null-input --compact-output \
    --arg url "${ib_sample_url}" \
    '{"url": $url, "prefer_small_media": true, "show_above_text": true}')"

keyboard_text1="Back"
keyboard_data1="post ${ib_board} ${ib_post_id}"

reply_markup="$(jq --null-input --compact-output \
    --arg text1 "${keyboard_text1}" \
    --arg data1 "${keyboard_data1}" \
    '{"inline_keyboard": [[{"text": $text1, "callback_data": $data1}]]}')"

if [[ ${ib_tags_offset} -gt 0 ]]
then
    keyboard_text1="Over"
    keyboard_data1="tags ${ib_board} ${ib_post_id}"

    reply_markup="$(printf "%s" "${reply_markup}" | jq --compact-output \
        --arg text1 "${keyboard_text1}" \
        --arg data1 "${keyboard_data1}" \
        '.inline_keyboard.[0] += [{"text": $text1, "callback_data": $data1}]')"
fi

if [[ $(($#ib_tags - ib_tags_offset - ib_tags_count)) -gt 0 ]]
then
    keyboard_text1="Next"
    keyboard_data1="tags ${ib_board} ${ib_post_id} $((ib_tags_offset + ib_tags_count))"

    reply_markup="$(printf "%s" "${reply_markup}" | jq --compact-output \
        --arg text1 "${keyboard_text1}" \
        --arg data1 "${keyboard_data1}" \
        '.inline_keyboard.[0] += [{"text": $text1, "callback_data": $data1}]')"
fi
