# Copyright (C) 2024-2025 Maria Lisina
# Copyright (C) 2024-2025 Danil Lisin
# SPDX-License-Identifier: Apache-2.0

if ! [[ -d "${user_config}" ]]
then
    output_text="No user data found"
    return 0
fi

until mkdir "${cache}/${user_id}.lock"
do
    sleep 1
done

rm -f "${cache}/${user_id}.tar"

if ! tar c -hf "${cache}/${user_id}.tar" "${user_config}"
then
    output_text="Something went wrong, try again later"

    rmdir "${cache}/${user_id}.lock"
    return 0
fi

if ! output_data="$(
    curl --connect-timeout ${connrefused_timeout} \
        --data-urlencode "chat_id=${chat_id}" \
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
        --form "chat_id=${chat_id}" \
        --form "document=@${cache}/${user_id}.tar" \
        --form "reply_parameters=${reply_parameters}" \
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
    output_text="Failed to send user data"

    log_text="sendDocument (${update_id}): Failed to access Telegram Bot API"
    . "${units}/log.zsh"

    rmdir "${cache}/${user_id}.lock"
    return 0
fi

if ! jq -e '.' <<< "${output_data}" > /dev/null
then
    output_text="An unknown error occurred"

    log_text="sendDocument (${update_id}): An unknown error occurred"
    . "${units}/log.zsh"

    rmdir "${cache}/${user_id}.lock"
    return 0
fi

if [[ "$(jq -r '.ok' <<< "${output_data}")" != "true" ]]
then
    output_text="Failed to send user data"
    error_description="$(jq -r '.description' <<< "${output_data}")"

    if [[ "${error_description}" != "null" ]]
    then
        log_text="sendDocument (${update_id}): ${error_description}"
    else
        log_text="sendDocument (${update_id}): An unknown error occurred"
    fi

    . "${units}/log.zsh"
fi

rmdir "${cache}/${user_id}.lock"
