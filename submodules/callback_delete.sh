# Copyright (C) 2024-2025 Maria Lisina
# Copyright (C) 2024-2025 Danil Lisin
# SPDX-License-Identifier: Apache-2.0

chat_id="$(jq -r '.callback_query.message.chat.id' "${update}")"
message_id="$(jq -r '.callback_query.message.message_id' "${update}")"

output_file="${cache}/${update_id}_deleteMessage.json"
dump="${dump} ${output_file##*/}"

if ! curl --data-urlencode "chat_id=${chat_id}" \
    --data-urlencode "message_id=${message_id}" \
    --get \
    --max-time ${internal_timeout} \
    --output "${output_file}" \
    --proxy "${internal_proxy}" \
    --silent \
    --user-agent "${useragent}" \
    "${api_address}/bot${api_token}/deleteMessage"
then
    notification_text="Failed to delete message"
    log_text="deleteMessage (${update_id}): Failed to access Telegram Bot API"

    . "${units}/log.sh"
    . "${units}/dump.sh"

    return 0
fi

if ! jq -e '.' "${output_file}" > /dev/null
then
    notification_text="An unknown error occurred"
    log_text="deleteMessage (${update_id}): An unknown error occurred"

    . "${units}/log.sh"
    . "${units}/dump.sh"

    return 0
fi

if [ "$(jq -r '.ok' "${output_file}")" != "true" ]
then
    notification_text="Failed to delete message"
    error_description="$(jq -r '.description' "${output_file}")"

    if [ "${error_description}" != "null" ]
    then
        log_text="deleteMessage (${update_id}): ${error_description}"
    else
        log_text="deleteMessage (${update_id}): An unknown error occurred"
    fi

    . "${units}/log.sh"
    . "${units}/dump.sh"
fi
