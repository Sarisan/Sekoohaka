# Copyright (C) 2024-2025 Maria Lisina
# Copyright (C) 2024-2025 Danil Lisin
# SPDX-License-Identifier: Apache-2.0

ib_lock=0
. "${units}/ib_common.sh"

if [ -n "${notification_text}" ]
then
    return 0
fi

ib_created_at="$(jq -r ".${ib_iarray}[${array_count}].${ib_icreated}" "${ib_file}")"
ib_file_size="$(jq -r ".${ib_iarray}[0].${ib_isize}" "${ib_file}")"
ib_file_url="$(jq -r ".${ib_iarray}[0].${ib_ifile}" "${ib_file}")"
ib_tags="$(jq -r ".${ib_iarray}[0].${ib_itags}" "${ib_file}" | htmlescape)"
ib_tags_offset=${1:-0}
ib_tags_total=0
ib_tags_count=0

. "${units}/ib_size.sh"
. "${units}/ib_meta.sh"

if [ -n "${ib_tags}" ] && [ "${ib_tags}" != "null" ]
then
    set -- ${ib_tags}
    ib_tags_total=${#}
else
    notification_text="Failed to get tags"
    return 0
fi

set -- ${ib_groups}
ib_groups_offset=${ib_tags_offset}

while [ ${#} -ge 2 ]
do
    ib_group_tags="$(jq -r ".${ib_iarray}[0].${1}" "${ib_file}" | htmlescape)"
    ib_group_name="${2}"
    ib_groups_saved="${@}"

    if [ -n "${ib_group_tags}" ] && [ "${ib_group_tags}" != "null" ]
    then
        set -- ${ib_group_tags}
        ib_group_count=${#}

        if [ ${ib_group_count} -gt ${ib_groups_offset} ]
        then
            shift ${ib_groups_offset}
            ib_groups_offset=0
        else
            ib_groups_offset=$((ib_groups_offset - ib_group_count))

            set -- ${ib_groups_saved}
            shift 2

            continue
        fi

        ib_group_text="$(printf "%s\n<b>%s:</b>" "${output_text}" "${ib_group_name}")"

        while [ ${#} -gt 0 ]
        do
            ib_tag="<code>${1}</code>"

            ib_tags_length=${#ib_group_text}
            ib_tag_length=${#ib_tag}

            if [ $((ib_tags_length + ib_tag_length)) -gt 2048 ]
            then
                break 2
            fi

            ib_group_text="${ib_group_text} ${ib_tag}"
            ib_tags_count=$((ib_tags_count + 1))

            output_text="${ib_group_text}"
            shift
        done
    fi

    set -- ${ib_groups_saved}
    shift 2
done

if [ -z "${output_text}" ]
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

if [ ${ib_tags_offset} -gt 0 ]
then
    keyboard_text1="Over"
    keyboard_data1="tags ${ib_board} ${ib_post_id}"

    reply_markup="$(printf "%s" "${reply_markup}" | jq --compact-output \
        --arg text1 "${keyboard_text1}" \
        --arg data1 "${keyboard_data1}" \
        '.inline_keyboard.[0] += [{"text": $text1, "callback_data": $data1}]')"
fi

if [ $((ib_tags_total - ib_tags_offset - ib_tags_count)) -gt 0 ]
then
    keyboard_text1="Next"
    keyboard_data1="tags ${ib_board} ${ib_post_id} $((ib_tags_offset + ib_tags_count))"

    reply_markup="$(printf "%s" "${reply_markup}" | jq --compact-output \
        --arg text1 "${keyboard_text1}" \
        --arg data1 "${keyboard_data1}" \
        '.inline_keyboard.[0] += [{"text": $text1, "callback_data": $data1}]')"
fi
