# Copyright (C) 2024-2026 Maria Lisina
# Copyright (C) 2024-2026 Danil Lisin
# SPDX-License-Identifier: Apache-2.0

uptime_table=(
    86400 d
    3600 h
    60 m
    1 s
)

uptime_time=$(($(strftime %s) - startup_time))

while [[ ${uptime_time} -gt 0 && ${#uptime_table} -ge 2 ]]
do
    uptime_unit=$((uptime_time / uptime_table[1]))

    if [[ ${uptime_unit} -eq 0 ]]
    then
        shift 2 uptime_table
        continue
    fi

    uptime_text="${uptime_text} ${uptime_unit}${uptime_table[2]}"

    uptime_time=$((uptime_time - (uptime_unit * uptime_table[1])))
    shift 2 uptime_table
done

latency_text=$(((latency_fin - latency_init) / 1000000))

output_text="$(printf "<b>Bot Status</b>\n<b>Uptime:</b>%s" "${uptime_text:- 0s}")"
output_text="$(printf "%s\n<b>Latency:</b> %ums" "${output_text}" "${latency_text}")"

keyboard_text1="Update"
keyboard_data1="status"

reply_markup="$(
    jq --null-input --compact-output \
        --arg text1 "${keyboard_text1}" \
        --arg data1 "${keyboard_data1}" \
        '{"inline_keyboard": [[{"text": $text1, "callback_data": $data1}]]}'
)"
