# Copyright (C) 2024-2025 Maria Lisina
# Copyright (C) 2024-2025 Danil Lisin
# SPDX-License-Identifier: Apache-2.0

ib_tag="$(jq -r ".${ib_iarray}[${array_count}].${ib_itag}" "${ib_file}")"
ib_count="$(jq -r ".${ib_iarray}[${array_count}].${ib_icount}" "${ib_file}")"

if [[ -n "${ib_irecode}" ]] && ib_tag_recode="$(printf "%s" "${ib_tag}" | recode ${ib_irecode}..ASCII)"
then
    ib_tag="${ib_tag_recode}"
fi

output_title="${ib_tag:- }"
output_text="$(printf "<b>%s</b>\n<b>ID:</b> <code>%s</code>" "${ib_name}" "${ib_id}")"
output_text="$(printf "%s\n<b>Name:</b> <code>%s</code>" "${output_text}" "$(printf "%s" "${ib_tag}" | htmlescape)")"
output_text="$(printf "%s\n<b>Post count:</b> %s" "${output_text}" "${ib_count}")"
output_description="Click to send the tag information"

keyboard_text1="Wiki link"
keyboard_url1="${ib_url}$(printf "%s" "${ib_tag}" | urlencode)"
keyboard_text2="Resume"
keyboard_query2="${command} ${ib_board} ${inline_page}"

if [[ -n "${search_query}" ]]
then
    keyboard_query2="${keyboard_query2} ${search_query}"
fi

result="$(jq --null-input --compact-output \
    --arg id "${ib_id}" \
    --arg title "${output_title}" \
    --arg text "${output_text}" \
    --arg description "${output_description}" \
    --arg text1 "${keyboard_text1}" \
    --arg url1 "${keyboard_url1}" \
    --arg text2 "${keyboard_text2}" \
    --arg query2 "${keyboard_query2}" \
    '{"type": "article", "id": $id, "title": $title, "input_message_content": {"message_text": $text, "parse_mode": "HTML"}, "description": $description, "reply_markup": {"inline_keyboard": [[{"text": $text1, "url": $url1}, {"text": $text2, "switch_inline_query_current_chat": $query2}]]}}')"

if [[ -n "${ib_quick}" ]]
then
    keyboard_text1="Search posts"
    keyboard_query1="p ${ib_board} ${ib_tag}"

    result="$(printf "%s" "${result}" | jq --compact-output \
        --arg text1 "${keyboard_text1}" \
        --arg query1 "${keyboard_query1}" \
        '.reply_markup.inline_keyboard += [[{"text": $text1, "switch_inline_query_current_chat": $query1}]]')"
fi
