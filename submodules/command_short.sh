# Copyright (C) 2024 Maria Lisina
# Copyright (C) 2024 Danil Lisin
# SPDX-License-Identifier: Apache-2.0

if [ -n "${1}" ]
then
    short_query="${@}"
    shift ${#}
else
    output_text="You must specify the query"
    return 0
fi

if [ ${#short_query} -gt 256 ]
then
    output_text="Query is too long"
    return 0
fi

output_text="<b>Shortcut:</b> <code>$(printf "%s" "${short_query}" | htmlescape)</code>"

keyboard_text1="Open inline"
keyboard_query1="${short_query}"

reply_markup="$(jq --null-input --compact-output \
    --arg text1 "${keyboard_text1}" \
    --arg query1 "${keyboard_query1}" \
    '{"inline_keyboard": [[{"text": $text1, "switch_inline_query_current_chat": $query1}]]}')"

short_query="short ${short_query}"

if [ ${#short_query} -le 64 ]
then
    keyboard_text1="Manage"
    keyboard_data1="${short_query}"

    reply_markup="$(printf "%s" "${reply_markup}" | jq --compact-output \
        --arg text1 "${keyboard_text1}" \
        --arg data1 "${keyboard_data1}" \
        '.inline_keyboard.[0] += [{"text": $text1, "callback_data": $data1}]')"
fi
