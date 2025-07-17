# Copyright (C) 2024-2025 Maria Lisina
# Copyright (C) 2024-2025 Danil Lisin
# SPDX-License-Identifier: Apache-2.0

if [[ "${chat_id}" != "${target_user}" ]]
then
    output_text="For security reasons you can execute this command only in the bot chat"
    return 0
fi

output_text="Remove all your data including login data and saved shortcuts"

keyboard_text1="Remove my data"
keyboard_data1="stop"

reply_markup="$(
    jq --null-input --compact-output \
        --arg text1 "${keyboard_text1}" \
        --arg data1 "${keyboard_data1}" \
        '{"inline_keyboard": [[{"text": $text1, "callback_data": $data1}]]}'
)"
