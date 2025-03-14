# Copyright (C) 2024-2025 Maria Lisina
# Copyright (C) 2024-2025 Danil Lisin
# SPDX-License-Identifier: Apache-2.0

. "${units}/ib_name.sh"
. "${units}/ib_common.sh"

if [ -n "${output_text}" ]
then
    return 0
fi

. "${units}/ib_original.sh"

if [ -n "${ib_file_url}" ] && [ "${ib_file_url}" != "null" ]
then
    keyboard_text1="Original file link"
    keyboard_url1="${ib_file_url}"

    reply_markup="$(jq --null-input --compact-output \
        --arg text1 "${keyboard_text1}" \
        --arg url1 "${keyboard_url1}" \
        '{"inline_keyboard": [[{"text": $text1, "url": $url1}]]}')"
fi

if [ -n "${output_text}" ]
then
    return 0
fi

curl --data-urlencode "chat_id=${chat_id}" \
    --data-urlencode "message_thread_id=${message_thread_id}" \
    --data-urlencode "action=upload_document" \
    --get \
    --max-time ${internal_timeout} \
    --proxy "${internal_proxy}" \
    --silent \
    "${api_address}/bot${api_token}/sendChatAction" > /dev/null

output_file="${cache}/${update_id}_sendDocument.json"

curl --data-urlencode "chat_id=${chat_id}" \
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
    "${api_address}/bot${api_token}/sendDocument"

if ! jq -e '.' "${output_file}" > /dev/null 2>&1
then
    output_text="An unknown error occurred"
    return 0
fi

if [ "$(jq -r '.ok' "${output_file}")" != "true" ]
then
    output_text="Failed to send the original file"
    return 0
fi

exit 0
