# Copyright (C) 2024 Maria Lisina
# Copyright (C) 2024 Danil Lisin
# SPDX-License-Identifier: Apache-2.0

until mkdir "${config}/${user_id}_short.lock" > /dev/null 2>&1
do
    sleep 1
done

short_config="${config}/${user_id}/short"
. "${units}/shorts_search.sh"

if [ -n "${output_text}" ]
then
    results="$(jq --null-input --compact-output \
        --arg id "${query_id}" \
        --arg title "${output_title}" \
        --arg text "${output_text}" \
        --arg description "${output_text}" \
        '[{"type": "article", "id": $id, "title": $title, "input_message_content": {"message_text": $text}, "description": $description}]')"

    rm -fr "${config}/${user_id}_short.lock"
    return 0
fi

results=[]
array_count=0

while [ ${#} -gt 0 ]
do
    short_query="$(cat "${short_config}/${1}")"

    output_title="Shortcut"
    output_text="<b>Shortcut:</b> <code>$(printf "%s" "${short_query}" | htmlescape)</code>"
    output_description="${short_query}"

    keyboard_text1="Open inline"
    keyboard_query1="${short_query}"

    result="$(jq --null-input --compact-output \
        --arg id "${1}" \
        --arg title "${output_title}" \
        --arg text "${output_text}" \
        --arg text1 "${keyboard_text1}" \
        --arg query1 "${keyboard_query1}" \
        --arg description "${output_description}" \
        '{"type": "article", "id": $id, "title": $title, "input_message_content": {"message_text": $text, "parse_mode": "HTML"}, "reply_markup": {"inline_keyboard": [[{"text": $text1, "switch_inline_query_current_chat": $query1}]]}, "description": $description}')"

    if [ "${chat_type}" = "sender" ]
    then
        keyboard_text1="Resume"
        keyboard_query1="${command} ${inline_page}"

        if [ -n "${inline_query}" ]
        then
            keyboard_query1="${keyboard_query1} ${inline_query}"
        fi

        result="$(printf "%s" "${result}" | jq --compact-output \
            --arg text1 "${keyboard_text1}" \
            --arg query1 "${keyboard_query1}" \
            '.reply_markup.inline_keyboard.[0] += [{"text": $text1, "switch_inline_query_current_chat": $query1}]')"
    fi

    if [ -n "${shorts_quick}" ]
    then
        keyboard_text1="Manage"
        keyboard_data1="short ${short_query}"

        result="$(printf "%s" "${result}" | jq --compact-output \
            --arg text1 "${keyboard_text1}" \
            --arg data1 "${keyboard_data1}" \
            '.reply_markup.inline_keyboard += [[{"text": $text1, "callback_data": $data1}]]')"
    fi

    results="$(printf "%s" "${results}" | jq -c ".[${array_count}] += ${result}")"
    array_count=$((array_count + 1))
    shift

    if [ ${array_count} -eq ${inline_limit} ]
    then
        break
    fi
done

if [ -n "${shorts_autopaging}" ]
then
    next_offset=$((inline_page + 1))
fi

rm -fr "${config}/${user_id}_short.lock"
