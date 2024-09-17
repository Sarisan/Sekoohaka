# Copyright (C) 2024 Maria Lisina
# Copyright (C) 2024 Danil Lisin
# SPDX-License-Identifier: Apache-2.0

output_text="Remove all your data including login data and saved shortcuts"

keyboard_text1="Remove my data"
keyboard_data1="stop"

reply_markup="$(jq --null-input --compact-output \
        --arg text1 "${keyboard_text1}" \
        --arg data1 "${keyboard_data1}" \
        '{"inline_keyboard": [[{"text": $text1, "callback_data": $data1}]]}')"
