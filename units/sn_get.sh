# Copyright (C) 2024-2025 Maria Lisina
# Copyright (C) 2024-2025 Danil Lisin
# SPDX-License-Identifier: Apache-2.0

message_id="$(jq -r '.message.reply_to_message.message_id' "${update}")"
file_id="$(jq -r '.message.reply_to_message.photo.[1].file_id' "${update}")"

if [ "${message_id}" = "null" ]
then
    output_text="You must use this command in reply to an image"
    return 0
fi

if [ "${file_id}" = "null" ]
then
    output_text="Could not find an image in replied message"
    return 0
fi

output_file="${cache}/${update_id}_getFile.json"
dump="${dump} ${output_file##*/}"

if ! curl --data-urlencode "file_id=${file_id}" \
    --get \
    --max-time ${internal_timeout} \
    --output "${output_file}" \
    --proxy "${internal_proxy}" \
    --silent \
    "${api_address}/bot${api_token}/getFile"
then
    output_text="An unknown error occurred"
    log_text="getFile (${update_id}): An unknown error occurred"

    . "${units}/log.sh"
    . "${units}/dump.sh"

    return 0
fi

if ! jq -e '.' "${output_file}" > /dev/null
then
    output_text="An unknown error occurred"
    log_text="getFile (${update_id}): An unknown error occurred"

    . "${units}/log.sh"
    . "${units}/dump.sh"

    return 0
fi

if [ "$(jq -r '.ok' "${output_file}")" != "true" ]
then
    output_text="An unknown error occurred"
    error_description="$(jq -r '.description' "${output_file}")"

    if [ "${error_description}" != "null" ]
    then
        log_text="getFile (${update_id}): ${error_description}"
    else
        log_text="getFile (${update_id}): An unknown error occurred"
    fi

    . "${units}/log.sh"
    . "${units}/dump.sh"

    return 0
fi

file_path="$(jq -r '.result.file_path' "${output_file}")"

if [ "${api_address}" = "127.0.0.1:8081" ] && ! ls "${file_path}" > /dev/null
then
    output_text="This command cannot be used, contact bot deployer"
    log_text="Error: sn_get: Cannot access Bot API working directory"

    . "${units}/log.sh"
fi
