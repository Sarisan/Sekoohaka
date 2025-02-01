# Copyright (C) 2024-2025 Maria Lisina
# Copyright (C) 2024-2025 Danil Lisin
# SPDX-License-Identifier: Apache-2.0

ib_lock=0
. "${units}/ib_common.sh"

if [ -n "${output_text}" ]
then
    results="$(jq --null-input --compact-output \
        --arg id "${query_id}" \
        --arg title "${output_title}" \
        --arg text "${output_text}" \
        --arg description "${output_text}" \
        '[{"type": "article", "id": $id, "title": $title, "input_message_content": {"message_text": $text}, "description": $description}]')"

    return 0
fi

. "${units}/ib_post.sh"

output_title="Information of post ${ib_post_id}"
output_description="Click to send the post information"

keyboard_text1="Post link"
keyboard_url1="${ib_url}$(printf "%s" "${ib_post_id}" | urlencode)"

results="$(jq --null-input --compact-output \
    --arg id "${query_id}" \
    --arg title "${output_title}" \
    --arg text "${output_text}" \
    --arg url "${ib_sample_url}" \
    --arg text1 "${keyboard_text1}" \
    --arg url1 "${keyboard_url1}" \
    --arg description "${output_description}" \
    --arg thumbnail_url "${ib_preview_url}" \
    '[{"type": "article", "id": $id, "title": $title, "input_message_content": {"message_text": $text, "parse_mode": "HTML", "link_preview_options": {"url": $url, "prefer_small_media": true, "show_above_text": true}}, "reply_markup": {"inline_keyboard": [[{"text": $text1, "url": $url1}]]}, "description": $description, "thumbnail_url": $thumbnail_url}]')"

if [ ${ib_tags_count} -gt 0 ]
then
    keyboard_text1="Tags (${ib_tags_count})"
    keyboard_data1="tags ${ib_board} ${ib_post_id}"

    results="$(printf "%s" "${results}" | jq --compact-output \
        --arg text1 "${keyboard_text1}" \
        --arg data1 "${keyboard_data1}" \
        '.[0].reply_markup.inline_keyboard[0] += [{"text": $text1, "callback_data": $data1}]')"
fi
