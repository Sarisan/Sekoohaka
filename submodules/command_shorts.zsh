# Copyright (C) 2024-2026 Maria Lisina
# Copyright (C) 2024-2026 Danil Lisin
# SPDX-License-Identifier: Apache-2.0

until mkdir "${user_config}_shorts.lock"
do
    sleep 1
done

shorts_config="${user_config}/shorts"

if [[ -d "${shorts_config}" ]]
then
    shorts=($(ls -1 "${shorts_config}"))
fi

if [[ ${#shorts} -eq 0 ]]
then
    output_text="You have no saved shortcuts yet"

    rmdir "${user_config}_shorts.lock"
    return
fi

output_text="<b>Saved shortcuts:</b> ${#shorts} / ${shorts_limit}"

keyboard_text1="Open inline"
keyboard_query1="shorts "

reply_markup="$(
    jq --null-input --compact-output \
        --arg text1 "${keyboard_text1}" \
        --arg query1 "${keyboard_query1}" \
        --arg text2 "${keyboard_text2}" \
        --arg data2 "${keyboard_data2}" \
        '{"inline_keyboard": [[{"text": $text1, "switch_inline_query_current_chat": $query1}]]}'
)"

if [[ "${chat_id}" == "${target_user}" ]]
then
    keyboard_text1="Remove all"
    keyboard_data1="stop shorts"

    reply_markup="$(
        jq --compact-output \
            --arg text1 "${keyboard_text1}" \
            --arg data1 "${keyboard_data1}" \
            '.inline_keyboard[0] += [{"text": $text1, "callback_data": $data1}]' \
        <<< "${reply_markup}"
    )"
fi

rmdir "${user_config}_shorts.lock"
