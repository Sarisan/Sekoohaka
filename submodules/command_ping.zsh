# Copyright (C) 2024-2025 Maria Lisina
# Copyright (C) 2024-2025 Danil Lisin
# SPDX-License-Identifier: Apache-2.0

output_text="Measuring..."
output_file="${cache}/${update_id}_sendMessage.json"
dump=(${dump[@]} ${output_file##*/})

latency_init=$(strftime %s%N)

if ! curl --data-urlencode "chat_id=${chat_id}" \
    --data-urlencode "message_thread_id=${message_thread_id}" \
    --data-urlencode "text=${output_text}" \
    --data-urlencode "reply_parameters=${reply_parameters}" \
    --get \
    --max-time ${internal_timeout} \
    --output "${output_file}" \
    --proxy "${internal_proxy}" \
    --silent \
    --user-agent "${useragent}" \
    "${api_address}/bot${api_token}/sendMessage"
then
    output_text="Failed to measure latency"
    log_text="sendMessage (${update_id}): Failed to access Telegram Bot API"

    . "${units}/log.zsh"
    . "${units}/dump.zsh"

    return 0
fi

latency_fin=$(strftime %s%N)

if ! jq -e '.' "${output_file}" > /dev/null
then
    output_text="An unknown error occurred"
    log_text="sendMessage (${update_id}): An unknown error occurred"

    . "${units}/log.zsh"
    . "${units}/dump.zsh"

    return 0
fi

if [[ "$(jq -r '.ok' "${output_file}")" != "true" ]]
then
    output_text="Failed to measure latency"
    error_description="$(jq -r '.description' "${output_file}")"

    if [[ "${error_description}" != "null" ]]
    then
        log_text="sendMessage (${update_id}): ${error_description}"
    else
        log_text="sendMessage (${update_id}): An unknown error occurred"
    fi

    . "${units}/log.zsh"
    . "${units}/dump.zsh"

    return 0
fi

chat_id="$(jq -r '.result.chat.id' "${output_file}")"
message_id="$(jq -r '.result.message_id' "${output_file}")"

latency=$(((latency_fin - latency_init) / 1000000))
output_text="$(printf "<b>Latency:</b> %ums" "${latency}")"

output_file="${cache}/${update_id}_editMessageText.json"
dump=(${dump[@]} ${output_file##*/})

if ! curl --data-urlencode "chat_id=${chat_id}" \
    --data-urlencode "message_id=${message_id}" \
    --data-urlencode "text=${output_text}" \
    --data-urlencode "parse_mode=HTML" \
    --get \
    --max-time ${internal_timeout} \
    --output "${output_file}" \
    --proxy "${internal_proxy}" \
    --silent \
    --user-agent "${useragent}" \
    "${api_address}/bot${api_token}/editMessageText"
then
    log_text="editMessageText (${update_id}): Failed to access Telegram Bot API"

    . "${units}/log.zsh"
    . "${units}/dump.zsh"

    exit 0
fi

if ! jq -e '.' "${output_file}" > /dev/null
then
    log_text="editMessageText (${update_id}): An unknown error occurred"

    . "${units}/log.zsh"
    . "${units}/dump.zsh"

    exit 0
fi

if [[ "$(jq -r '.ok' "${output_file}")" != "true" ]]
then
    error_description="$(jq -r '.description' "${output_file}")"

    if [[ "${error_description}" != "null" ]]
    then
        log_text="editMessageText (${update_id}): ${error_description}"
    else
        log_text="editMessageText (${update_id}): An unknown error occurred"
    fi

    . "${units}/log.zsh"
    . "${units}/dump.zsh"
fi

exit 0
