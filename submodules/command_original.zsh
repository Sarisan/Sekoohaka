# Copyright (C) 2024-2025 Maria Lisina
# Copyright (C) 2024-2025 Danil Lisin
# SPDX-License-Identifier: Apache-2.0

. "${units}/ib_name.zsh"
. "${units}/ib_common.zsh"

if [[ -n "${output_text}" ]]
then
    return 0
fi

. "${units}/ib_original.zsh"

if [[ -n "${ib_file_url}" && "${ib_file_url}" != "null" ]]
then
    keyboard_text1="Original file link"
    keyboard_url1="${ib_file_url}"

    reply_markup="$(jq --null-input --compact-output \
        --arg text1 "${keyboard_text1}" \
        --arg url1 "${keyboard_url1}" \
        '{"inline_keyboard": [[{"text": $text1, "url": $url1}]]}')"
fi

if [[ -n "${output_text}" ]]
then
    return 0
fi

output_file="${cache}/${update_id}_sendChatAction.json"
dump=(${dump[@]} ${output_file##*/})

if ! curl --data-urlencode "chat_id=${chat_id}" \
    --data-urlencode "message_thread_id=${message_thread_id}" \
    --data-urlencode "action=upload_document" \
    --get \
    --max-time ${internal_timeout} \
    --output "${output_file}" \
    --proxy "${internal_proxy}" \
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
dump=(${dump[@]} ${output_file##*/})

if ! curl --data-urlencode "chat_id=${chat_id}" \
    --data-urlencode "message_thread_id=${message_thread_id}" \
    --data-urlencode "document=${ib_file_url}" \
    --data-urlencode "thumbnail=${ib_preview_url}" \
    --data-urlencode "reply_parameters=${reply_parameters}" \
    --data-urlencode "reply_markup=${reply_markup}" \
    --get \
    --max-time ${internal_timeout} \
    --output "${output_file}" \
    --proxy "${internal_proxy}" \
    --silent \
    --user-agent "${useragent}" \
    "${api_address}/bot${api_token}/sendDocument"
then
    output_text="Failed to send the original file"
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
    output_text="Failed to send the original file"
    error_description="$(jq -r '.description' "${output_file}")"

    if [[ "${error_description}" != "null" ]]
    then
        log_text="sendDocument (${update_id}): ${error_description}"
    else
        log_text="sendDocument (${update_id}): An unknown error occurred"
    fi

    . "${units}/log.zsh"
    . "${units}/dump.zsh"

    return 0
fi

exit 0
