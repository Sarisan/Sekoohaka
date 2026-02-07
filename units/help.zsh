# Copyright (C) 2024-2026 Maria Lisina
# Copyright (C) 2024-2026 Danil Lisin
# SPDX-License-Identifier: Apache-2.0

while [[ ${#help_table} -ge 3 ]]
do
    keyboard_text1="${help_table[2]}"
    keyboard_data1="help ${help_table[1]}"

    reply_markup="$(
        jq --compact-output \
            --argjson offset "$(printf "%u" "${keyboard_offset}")" \
            --arg text1 "${keyboard_text1}" \
            --arg data1 "${keyboard_data1}" \
            '.inline_keyboard[$offset] += [{"text": $text1, "callback_data": $data1}]' \
        <<< "${reply_markup:-"{}"}"
    )"

    keyboard_offset=$((keyboard_offset + 0.5))
    shift 3 help_table
done
