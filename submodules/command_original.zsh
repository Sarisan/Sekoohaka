# Copyright (C) 2024-2025 Maria Lisina
# Copyright (C) 2024-2025 Danil Lisin
# SPDX-License-Identifier: Apache-2.0

. "${units}/ib_name.zsh"

if [[ -n "${output_text}" ]]
then
    return 0
fi

. "${units}/ib_common.zsh"

if [[ -n "${output_text}" ]]
then
    return 0
fi

ib_hash="$(sha1sum <<< "${user_id}${ib_board}${ib_query}" | cut -d ' ' -f 1)"
ib_file="${cache}/${ib_hash}.json"

until mkdir "${cache}/${ib_hash}.lock"
do
    sleep 1
done

. "${units}/ib_file.zsh"

if [[ -n "${output_text}" ]]
then
    rmdir "${cache}/${ib_hash}.lock"
    return 0
fi

. "${units}/ib_original.zsh"

if [[ -n "${ib_file_url}" && "${ib_file_url}" != "null" ]]
then
    keyboard_text1="Original file link"
    keyboard_url1="${ib_file_url}"

    reply_markup="$(
        jq --null-input --compact-output \
            --arg text1 "${keyboard_text1}" \
            --arg url1 "${keyboard_url1}" \
            '{"inline_keyboard": [[{"text": $text1, "url": $url1}]]}'
    )"
fi

if [[ -n "${output_text}" ]]
then
    rmdir "${cache}/${ib_hash}.lock"
    return 0
fi

if ! output_data="$(
    curl --connect-timeout ${connrefused_timeout} \
        --data-urlencode "chat_id=${chat_id}" \
        --data-urlencode "message_thread_id=${message_thread_id}" \
        --data-urlencode "action=upload_document" \
        --get \
        --max-time ${internal_timeout} \
        --proxy "${internal_proxy}" \
        --retry 1 \
        --retry-connrefused \
        --retry-max-time $((internal_timeout - connrefused_timeout)) \
        --silent \
        --user-agent "${useragent}" \
        "${api_address}/bot${api_token}/sendChatAction"
)"
then
    log_text="sendChatAction (${update_id}): Failed to access Telegram Bot API"
    . "${units}/log.zsh"
fi

if [[ -z "${log_text}" ]] && ! jq -e '.' <<< "${output_data}" > /dev/null
then
    log_text="sendChatAction (${update_id}): An unknown error occurred"
    . "${units}/log.zsh"
fi

if [[ -z "${log_text}" && "$(jq -r '.ok' <<< "${output_data}")" != "true" ]]
then
    error_description="$(jq -r '.description' <<< "${output_data}")"

    if [[ "${error_description}" != "null" ]]
    then
        log_text="sendChatAction (${update_id}): ${error_description}"
    else
        log_text="sendChatAction (${update_id}): An unknown error occurred"
    fi

    . "${units}/log.zsh"
fi

if ! output_data="$(
    curl --connect-timeout ${connrefused_timeout} \
        --data-urlencode "chat_id=${chat_id}" \
        --data-urlencode "message_thread_id=${message_thread_id}" \
        --data-urlencode "document=${ib_file_url}" \
        --data-urlencode "thumbnail=${ib_preview_url}" \
        --data-urlencode "reply_parameters=${reply_parameters}" \
        --data-urlencode "reply_markup=${reply_markup}" \
        --get \
        --max-time ${internal_timeout} \
        --proxy "${internal_proxy}" \
        --retry 1 \
        --retry-connrefused \
        --retry-max-time $((internal_timeout - connrefused_timeout)) \
        --silent \
        --user-agent "${useragent}" \
        "${api_address}/bot${api_token}/sendDocument"
)"
then
    output_text="Failed to send original file"

    log_text="sendDocument (${update_id}): Failed to access Telegram Bot API"
    . "${units}/log.zsh"

    rmdir "${cache}/${ib_hash}.lock"
    return 0
fi

if ! jq -e '.' <<< "${output_data}" > /dev/null
then
    output_text="An unknown error occurred"

    log_text="sendDocument (${update_id}): An unknown error occurred"
    . "${units}/log.zsh"

    rmdir "${cache}/${ib_hash}.lock"
    return 0
fi

if [[ "$(jq -r '.ok' <<< "${output_data}")" != "true" ]]
then
    output_text="Failed to send original file"
    error_description="$(jq -r '.description' <<< "${output_data}")"

    if [[ "${error_description}" != "null" ]]
    then
        log_text="sendDocument (${update_id}): ${error_description}"
    else
        log_text="sendDocument (${update_id}): An unknown error occurred"
    fi

    . "${units}/log.zsh"

    rmdir "${cache}/${ib_hash}.lock"
    return 0
fi

rmdir "${cache}/${ib_hash}.lock"
exit 0
