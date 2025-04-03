# Copyright (C) 2024-2025 Maria Lisina
# Copyright (C) 2024-2025 Danil Lisin
# SPDX-License-Identifier: Apache-2.0

until mkdir "${user_config}_short.lock"
do
    sleep 1
done

short_config="${user_config}/short"

if [ -d "${short_config}" ]
then
    shorts="$(ls -x "${short_config}")"
fi

set -- ${shorts}

if [ ${#} -gt 0 ]
then
    output_text="<b>Saved shortcuts:</b> ${#} / ${shorts_limit}"

    keyboard_text1="Open inline"
    keyboard_query1="shorts"
    keyboard_text2="Remove all"
    keyboard_data2="reset"

    reply_markup="$(jq --null-input --compact-output \
        --arg text1 "${keyboard_text1}" \
        --arg query1 "${keyboard_query1}" \
        --arg text2 "${keyboard_text2}" \
        --arg data2 "${keyboard_data2}" \
        '{"inline_keyboard": [[{"text": $text1, "switch_inline_query_current_chat": $query1}, {"text": $text2, "callback_data": $data2}]]}')"
else
    output_text="You have no saved shortcuts yet"
fi

rm -fr "${user_config}_short.lock"
