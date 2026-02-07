# Copyright (C) 2024-2026 Maria Lisina
# Copyright (C) 2024-2026 Danil Lisin
# SPDX-License-Identifier: Apache-2.0

if [[ -n "${1}" ]]
then
    data_name="${1}"
    check_table=(${help_table[@]})
    shift
fi

while [[ ${#check_table} -ge 3 ]]
do
    if [[ "${data_name}" == "${check_table[1]}" ]]
    then
        break
    elif [[ "${check_table[1]}" == "${check_table[-3]}" ]]
    then
        notification_text="No requested topic found"
        return
    fi

    shift 3 check_table
done

link_preview_options="$(
    jq --null-input --compact-output \
        '{"is_disabled": true}'
)"

if [[ -n "${data_name}" ]]
then
    output_text="${check_table[3]}"

    keyboard_text1="Back"
    keyboard_data1="help"

    reply_markup="$(
        jq --null-input --compact-output \
            --arg text1 "${keyboard_text1}" \
            --arg data1 "${keyboard_data1}" \
            '{"inline_keyboard": [[{"text": $text1, "callback_data": $data1}]]}'
    )"
else
    output_text="${help_general}"
    . "${units}/help.zsh"
fi
