# Copyright (C) 2024-2025 Maria Lisina
# Copyright (C) 2024-2025 Danil Lisin
# SPDX-License-Identifier: Apache-2.0

if ! [[ -d "${user_config}" ]]
then
    output_text="No user data found"
    return 0
fi

rm -f "${cache}/${user_id}.tar"

if ! tar c -hf "${cache}/${user_id}.tar" "${user_config}"
then
    output_text="Something went wrong, try again later"
    return 0
fi

output_file="${cache}/${update_id}_sendChatAction.json"
dump+=(${output_file##*/})

if ! curl --connect-timeout ${connrefused_timeout} \
    --data-urlencode "chat_id=${chat_id}" \
    --data-urlencode "action=upload_document" \
    --get \
    --max-time ${internal_timeout} \
    --output "${output_file}" \
    --proxy "${internal_proxy}" \
    --retry 1 \
    --retry-connrefused \
    --retry-max-time $((internal_timeout - connrefused_timeout)) \
    --silent \
    --user-agent "${useragent}" \
    "${api_address}/bot${api_token}/sendChatAction"
then
    log_text="sendChatAction (${update_id}): Failed to access Telegram Bot API"

    . "${units}/log.zsh"
    . "${units}/dump.zsh"
fi

if [[ -z "${log_text}" ]] && ! jq -e '.' "${output_file}" > /dev/null
then
    log_text="sendChatAction (${update_id}): An unknown error occurred"

    . "${units}/log.zsh"
    . "${units}/dump.zsh"
fi

if [[ -z "${log_text}" && "$(jq -r '.ok' "${output_file}")" != "true" ]]
then
    error_description="$(jq -r '.description' "${output_file}")"

    if [[ "${error_description}" != "null" ]]
    then
        log_text="sendChatAction (${update_id}): ${error_description}"
    else
        log_text="sendChatAction (${update_id}): An unknown error occurred"
    fi

    . "${units}/log.zsh"
    . "${units}/dump.zsh"
fi

output_file="${cache}/${update_id}_sendDocument.json"
dump+=(${output_file##*/})

if ! curl --connect-timeout ${connrefused_timeout} \
    --form "chat_id=${chat_id}" \
    --form "document=@${cache}/${user_id}.tar" \
    --form "reply_parameters=${reply_parameters}" \
    --get \
    --max-time ${internal_timeout} \
    --output "${output_file}" \
    --proxy "${internal_proxy}" \
    --retry 1 \
    --retry-connrefused \
    --retry-max-time $((internal_timeout - connrefused_timeout)) \
    --silent \
    --user-agent "${useragent}" \
    "${api_address}/bot${api_token}/sendDocument"
then
    output_text="Failed to send the user data"
    log_text="sendDocument (${update_id}): Failed to access Telegram Bot API"

    . "${units}/log.zsh"
    . "${units}/dump.zsh"

    return 0
fi

if ! jq -e '.' "${output_file}" > /dev/null
then
    output_text="An unknown error occurred"
    log_text="sendDocument (${update_id}): An unknown error occurred"

    . "${units}/log.zsh"
    . "${units}/dump.zsh"

    return 0
fi

if [[ "$(jq -r '.ok' "${output_file}")" != "true" ]]
then
    output_text="Failed to send the user data"
    error_description="$(jq -r '.description' "${output_file}")"

    if [[ "${error_description}" != "null" ]]
    then
        log_text="sendDocument (${update_id}): ${error_description}"
    else
        log_text="sendDocument (${update_id}): An unknown error occurred"
    fi

    . "${units}/log.zsh"
    . "${units}/dump.zsh"
fi
