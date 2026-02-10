# Copyright (C) 2024-2026 Maria Lisina
# Copyright (C) 2024-2026 Danil Lisin
# SPDX-License-Identifier: Apache-2.0

output_text="Measuring latency..."
latency_init=$(strftime %s%N)

if ! output_data="$(
    curl --connect-timeout ${connrefused_timeout} \
        --data-urlencode "chat_id=${chat_id}" \
        --data-urlencode "message_id=${message_id}" \
        --data-urlencode "text=${output_text}" \
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
    notification_text="Failed to measure latency"

    log_text="editMessageText (${update_id}): Failed to access Telegram Bot API"
    source "${units}/log.zsh"

    return
fi

latency_fin=$(strftime %s%N)

if ! jq -e '.' <<< "${output_data}" > /dev/null
then
    notification_text="An unknown error occurred"

    log_text="editMessageText (${update_id}): An unknown error occurred"
    source "${units}/log.zsh"

    return
fi

if [[ "$(jq -r '.ok' <<< "${output_data}")" != "true" ]]
then
    notification_text="Failed to measure latency"
    error_description="$(jq -r '.description' <<< "${output_data}")"

    if [[ "${error_description}" != "null" ]]
    then
        log_text="editMessageText (${update_id}): ${error_description}"
    else
        log_text="editMessageText (${update_id}): An unknown error occurred"
    fi

    source "${units}/log.zsh"
    return
fi

. "${units}/ping.zsh"
