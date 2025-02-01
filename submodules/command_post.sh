# Copyright (C) 2024-2025 Maria Lisina
# Copyright (C) 2024-2025 Danil Lisin
# SPDX-License-Identifier: Apache-2.0

if [ -z "${1}" ]
then
    reply_text="$(jq -r '.message.reply_to_message.text' "${update}")"

    if [ "${reply_text}" = "null" ]
    then
        reply_text="$(jq -r '.message.reply_to_message.caption' "${update}")"
    fi

    if [ "${reply_text}" != "null" ]
    then
        ib_reply_name="$(printf "%s" "${reply_text}" | sed '1!d')"
        ib_post_id="$(printf "%s" "${reply_text}" | grep 'ID' | parameter 2)"

        for ib_board in ${ascii_table}
        do
            . "${units}/ib_config.sh"

            if [ "${ib_reply_name}" = "${ib_name}" ]
            then
                break
            fi
        done

        set -- ${ib_board} ${ib_post_id}
    fi
fi

. "${units}/ib_common.sh"

if [ -n "${output_text}" ]
then
    return 0
fi

. "${units}/ib_post.sh"

link_preview_options="$(jq --null-input --compact-output \
    --arg url "${ib_sample_url}" \
    '{"url": $url, "prefer_small_media": true, "show_above_text": true}')"

keyboard_text1="Post link"
keyboard_url1="${ib_url}$(printf "%s" "${ib_post_id}" | urlencode)"

reply_markup="$(jq --null-input --compact-output \
    --arg text1 "${keyboard_text1}" \
    --arg url1 "${keyboard_url1}" \
    '{"inline_keyboard": [[{"text": $text1, "url": $url1}]]}')"

if [ ${ib_tags_count} -gt 0 ]
then
    keyboard_text1="Tags (${ib_tags_count})"
    keyboard_data1="tags ${ib_board} ${ib_post_id}"

    reply_markup="$(printf "%s" "${reply_markup}" | jq --compact-output \
        --arg text1 "${keyboard_text1}" \
        --arg data1 "${keyboard_data1}" \
        '.inline_keyboard.[0] += [{"text": $text1, "callback_data": $data1}]')"
fi
