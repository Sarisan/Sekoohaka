# Copyright (C) 2024-2025 Maria Lisina
# Copyright (C) 2024-2025 Danil Lisin
# SPDX-License-Identifier: Apache-2.0

ib_created_at="${ib_created_ats[idx]}"
ib_pool="${ib_pools[idx]}"
ib_count="${ib_counts[idx]}"

unset ib_date_text
. "${units}/ib_date.zsh"

if [[ -n "${ib_ispace}" ]]
then
    ib_pool="$(tr "${ib_ispace}" ' ' <<< "${ib_pool}")"
fi

if [[ ${#ib_pool} -gt 1024 ]]
then
    ib_pool="$(cut -c 1-1024 <<< "${ib_pool}")..."
fi

output_title="${ib_pool:- }"
output_text="$(printf "<b>%s</b>\n<b>ID:</b> <code>%s</code>" "${ib_name}" "${ib_id}")"

if [[ -n "${ib_date_text}" ]]
then
    output_text="$(printf "%s\n<b>Date:</b> <code>%s</code>" "${output_text}" "${ib_date_text}")"
fi

output_text="$(printf "%s\n<b>Name:</b> %s" "${output_text}" "$(htmlescape <<< "${ib_pool}")")"
output_text="$(printf "%s\n<b>Post count:</b> %s" "${output_text}" "${ib_count}")"
output_description="Click to send pool information"

keyboard_text1="Pool link"
keyboard_url1="${ib_url}$(urlencode <<< "${ib_id}")"
keyboard_text2="Resume"
keyboard_query2="${command} ${ib_board} ${inline_page}"

if [[ -n "${search_query}" ]]
then
    keyboard_query2="${keyboard_query2} ${search_query}"
fi

result="$(
    jq --null-input --compact-output \
        --arg id "${ib_id}" \
        --arg title "${output_title}" \
        --arg text "${output_text}" \
        --arg description "${output_description}" \
        --arg text1 "${keyboard_text1}" \
        --arg url1 "${keyboard_url1}" \
        --arg text2 "${keyboard_text2}" \
        --arg query2 "${keyboard_query2}" \
        '{"type": "article", "id": $id, "title": $title, "input_message_content": {"message_text": $text, "parse_mode": "HTML"}, "description": $description, "reply_markup": {"inline_keyboard": [[{"text": $text1, "url": $url1}, {"text": $text2, "switch_inline_query_current_chat": $query2}]]}}'
)"

if [[ -n "${ib_quick}" ]]
then
    keyboard_text1="Search posts"
    keyboard_query1="posts ${ib_board} pool:${ib_id}"

    if [[ -n "${ib_iorder}" ]]
    then
        keyboard_query1="${keyboard_query1} ${ib_iorder}"
    fi

    result="$(
        jq --compact-output \
            --arg text1 "${keyboard_text1}" \
            --arg query1 "${keyboard_query1}" \
            '.reply_markup.inline_keyboard += [[{"text": $text1, "switch_inline_query_current_chat": $query1}]]' \
        <<< "${result}"
    )"
fi
