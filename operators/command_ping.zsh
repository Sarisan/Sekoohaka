# Copyright (C) 2024-2026 Maria Lisina
# Copyright (C) 2024-2026 Danil Lisin
# SPDX-License-Identifier: Apache-2.0

output_text="Measuring latency..."
latency_sysf=$(strftime %s%N)
latency_net=$(strftime %s%N)

if ! output_data="$(
    curl --connect-timeout ${connrefused_timeout} \
        --data-urlencode "chat_id=${chat_id}" \
        --data-urlencode "message_thread_id=${message_thread_id}" \
        --data-urlencode "text=${output_text}" \
        --data-urlencode "reply_parameters=${reply_parameters}" \
        --get \
        --max-time ${internal_timeout} \
        --proxy "${internal_proxy}" \
        --retry 1 \
        --retry-connrefused \
        --retry-max-time $((internal_timeout - connrefused_timeout)) \
        --silent \
        --user-agent "${useragent}" \
        "${api_address}/bot${api_token}/sendMessage"
)"
then
    output_text="Failed to measure latency"

    log_text="sendMessage (${update_id}): Failed to access Telegram Bot API"
    source "${units}/log.zsh"

    return
fi

latency_netf=$(strftime %s%N)

if ! jq -e '.' <<< "${output_data}" > /dev/null
then
    output_text="An unknown error occurred"

    log_text="sendMessage (${update_id}): An unknown error occurred"
    source "${units}/log.zsh"

    return
fi

if [[ "$(jq -r '.ok' <<< "${output_data}")" != "true" ]]
then
    output_text="Failed to measure latency"
    error_description="$(jq -r '.description' <<< "${output_data}")"

    if [[ "${error_description}" != "null" ]]
    then
        log_text="sendMessage (${update_id}): ${error_description}"
    else
        log_text="sendMessage (${update_id}): An unknown error occurred"
    fi

    source "${units}/log.zsh"
    return
fi

message_id="$(jq -r '.result.message_id' <<< "${output_data}")"
. "${units}/ping.zsh"

if ! output_data="$(
    curl --connect-timeout ${connrefused_timeout} \
        --data-urlencode "chat_id=${chat_id}" \
        --data-urlencode "message_id=${message_id}" \
        --data-urlencode "text=${output_text}" \
        --data-urlencode "parse_mode=HTML" \
        --data-urlencode "reply_markup=${reply_markup}" \
        --get \
        --max-time ${internal_timeout} \
        --proxy "${internal_proxy}" \
        --retry 1 \
        --retry-connrefused \
        --retry-max-time $((internal_timeout - connrefused_timeout)) \
        --silent \
        --user-agent "${useragent}" \
        "${api_address}/bot${api_token}/editMessageText"
)"
then
    log_text="editMessageText (${update_id}): Failed to access Telegram Bot API"
    source "${units}/log.zsh"

    exit
fi

if ! jq -e '.' <<< "${output_data}" > /dev/null
then
    log_text="editMessageText (${update_id}): An unknown error occurred"
    source "${units}/log.zsh"

    exit
fi

if [[ "$(jq -r '.ok' <<< "${output_data}")" != "true" ]]
then
    error_description="$(jq -r '.description' <<< "${output_data}")"

    if [[ "${error_description}" != "null" ]]
    then
        log_text="editMessageText (${update_id}): ${error_description}"
    else
        log_text="editMessageText (${update_id}): An unknown error occurred"
    fi

    source "${units}/log.zsh"
fi

exit
