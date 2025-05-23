# Copyright (C) 2024-2025 Maria Lisina
# Copyright (C) 2024-2025 Danil Lisin
# SPDX-License-Identifier: Apache-2.0

message_id="$(jq -r '.message.reply_to_message.message_id' "${update}")"
file_id="$(jq -r '.message.reply_to_message.photo.[1].file_id' "${update}")"

if [[ "${message_id}" = "null" || "${message_id}" = "${message_thread_id}" ]]
then
    output_text="You must use this command in reply to an image"
    return 0
fi

if [[ "${file_id}" = "null" ]]
then
    output_text="Could not find an image in replied message"
    return 0
fi

output_file="${cache}/${update_id}_getFile.json"
dump=(${dump[@]} ${output_file##*/})

if ! curl --data-urlencode "file_id=${file_id}" \
    --get \
    --max-time ${internal_timeout} \
    --output "${output_file}" \
    --proxy "${internal_proxy}" \
    --silent \
    --user-agent "${useragent}" \
    "${api_address}/bot${api_token}/getFile"
then
    output_text="Failed to get the image file"
    log_text="getFile (${update_id}): Failed to access Telegram Bot API"

    . "${units}/log.zsh"
    . "${units}/dump.zsh"

    return 0
fi

if ! jq -e '.' "${output_file}" > /dev/null
then
    output_text="An unknown error occurred"
    log_text="getFile (${update_id}): An unknown error occurred"

    . "${units}/log.zsh"
    . "${units}/dump.zsh"

    return 0
fi

if [[ "$(jq -r '.ok' "${output_file}")" != "true" ]]
then
    output_text="Failed to get the image file"
    error_description="$(jq -r '.description' "${output_file}")"

    if [[ "${error_description}" != "null" ]]
    then
        log_text="getFile (${update_id}): ${error_description}"
    else
        log_text="getFile (${update_id}): An unknown error occurred"
    fi

    . "${units}/log.zsh"
    . "${units}/dump.zsh"

    return 0
fi

file_path="$(jq -r '.result.file_path' "${output_file}")"

if [[ "${api_address}" = "${local_address}" ]] && ! ls "${file_path}" > /dev/null
then
    output_text="There is an error on the bot side, please contact bot deployer"
    log_text="Error: sn_get: Cannot access Telegram Bot API working directory"

    . "${units}/log.zsh"
    return 0
fi

if [[ "${api_address}" = "${default_address}" ]]
then
    output_file="${cache}/${update_id}_file.jpg"
    dump=(${dump[@]} ${output_file##*/})

    if ! curl --max-time ${internal_timeout} \
        --output "${output_file}" \
        --proxy "${internal_proxy}" \
        --silent \
        --user-agent "${useragent}" \
        "${api_address}/file/bot${api_token}/${file_path}"
    then
        output_text="Failed to download the image file"
        log_text="getFile (${update_id}): Failed to access Telegram Bot API"

        . "${units}/log.zsh"
        . "${units}/dump.zsh"

        return 0
    fi

    if [[ "$(jq -r '.ok' "${output_file}")" = "false" ]]
    then
        output_text="Failed to download the image file"
        error_description="$(jq -r '.description' "${output_file}")"

        if [[ "${error_description}" != "null" ]]
        then
            log_text="getFile (${update_id}): ${error_description}"
        else
            log_text="getFile (${update_id}): An unknown error occurred"
        fi

        . "${units}/log.zsh"
        . "${units}/dump.zsh"

        return 0
    fi

    file_path="${output_file}"
fi

sn_query="file=@${file_path}"
. "${units}/sn_search.zsh"
