# Copyright (C) 2024-2025 Maria Lisina
# Copyright (C) 2024-2025 Danil Lisin
# SPDX-License-Identifier: Apache-2.0

if [[ -d "${user_config}" ]]
then
    user_data=($(ls -1 "${user_config}"))
fi

if [[ ${#user_data} -eq 0 ]]
then
    output_text="You have no data to remove"
    return 0
fi

output_text="Remove all your data or specific one"

while [[ ${#data_table} -ge 2 ]]
do
    if ! [[ -a "${user_config}/${data_table[2]}" ]]
    then
        shift 2 data_table
        continue
    fi

    keyboard_text1="${data_table[1]}"
    keyboard_data1="stop ${data_table[2]}"

    reply_markup="$(
        jq --compact-output \
            --argjson offset "$(printf "%u" "${keyboard_offset}")" \
            --arg text1 "${keyboard_text1}" \
            --arg data1 "${keyboard_data1}" \
            '.inline_keyboard[$offset] += [{"text": $text1, "callback_data": $data1}]' \
        <<< "${reply_markup:-"{}"}"
    )"

    keyboard_offset=$((keyboard_offset + 0.5))
    shift 2 data_table
done

keyboard_text1="Remove all my data"
keyboard_data1="stop"

reply_markup="$(
    jq --compact-output \
        --argjson offset "$(printf "%u" "$((keyboard_offset + 0.5))")" \
        --arg text1 "${keyboard_text1}" \
        --arg data1 "${keyboard_data1}" \
        '.inline_keyboard[$offset] += [{"text": $text1, "callback_data": $data1}]' \
    <<< "${reply_markup}"
)"
