# Copyright (C) 2024-2025 Maria Lisina
# Copyright (C) 2024-2025 Danil Lisin
# SPDX-License-Identifier: Apache-2.0

if [ -n "${1}" ]
then
    short_query="${@}"
    shift ${#}
else
    output_title="Invalid arguments"
    output_text="You must specify the query"

    results="$(jq --null-input --compact-output \
        --arg id "${query_id}" \
        --arg title "${output_title}" \
        --arg text "${output_text}" \
        --arg description "${output_text}" \
        '[{"type": "article", "id": $id, "title": $title, "input_message_content": {"message_text": $text}, "description": $description}]')"

    return 0
fi

output_title="Shortcut"
output_text="<b>Shortcut:</b> <code>$(printf "%s" "${short_query}" | htmlescape)</code>"
output_description="${short_query}"

keyboard_text1="Open inline"
keyboard_query1="${short_query}"

results="$(jq --null-input --compact-output \
    --arg id "${query_id}" \
    --arg title "${output_title}" \
    --arg text "${output_text}" \
    --arg text1 "${keyboard_text1}" \
    --arg query1 "${keyboard_query1}" \
    --arg description "${output_description}" \
    '[{"type": "article", "id": $id, "title": $title, "input_message_content": {"message_text": $text, "parse_mode": "HTML"}, "reply_markup": {"inline_keyboard": [[{"text": $text1, "switch_inline_query_current_chat": $query1}]]}, "description": $description}]')"

short_query="short ${short_query}"

if [ ${#short_query} -le 64 ]
then
    keyboard_text1="Manage"
    keyboard_data1="${short_query}"

    results="$(printf "%s" "${results}" | jq --compact-output \
        --arg text1 "${keyboard_text1}" \
        --arg data1 "${keyboard_data1}" \
        '.[0].reply_markup.inline_keyboard[0] += [{"text": $text1, "callback_data": $data1}]')"
fi
