# Copyright (C) 2024-2026 Maria Lisina
# Copyright (C) 2024-2026 Danil Lisin
# SPDX-License-Identifier: Apache-2.0

if [[ -n "${nocommand_source}" ]]
then
    exit 0
fi

user_id="$(jq -r '.message.from.id' <<< "${update}")"
chat_id="$(jq -r '.message.chat.id' <<< "${update}")"

if [[ "${chat_id}" != "${user_id}" ]]
then
    exit 0
fi

file_id="$(jq -r '.message.photo.[1].file_id' <<< "${update}")"

if [[ "${file_id}" == "null" ]]
then
    exit 0
fi

via_bot="$(jq -r '.message.via_bot.username' <<< "${update}")"

if [[ "${via_bot}" == "${username}" ]]
then
    exit 0
fi

message_id="$(jq -r '.message.message_id' <<< "${update}")"
is_topic="$(jq -r '.message.is_topic_message' <<< "${update}")"
message_thread_id="$(jq -r '.message.message_thread_id' <<< "${update}")"

reply_parameters="$(
    jq --null-input --compact-output \
        --arg message_id "${message_id}" \
        '{"message_id": $message_id, "allow_sending_without_reply": true}'
)"

if [[ "${is_topic}" == "null" ]]
then
    unset message_thread_id
fi

source "${units}/user.zsh"
source "${operators}/command_source.zsh"

if ! output_data="$(
    curl --connect-timeout ${connrefused_timeout} \
        --data-urlencode "chat_id=${chat_id}" \
        --data-urlencode "message_thread_id=${message_thread_id}" \
        --data-urlencode "text=${output_text}" \
        --data-urlencode "parse_mode=HTML" \
        --data-urlencode "link_preview_options=${link_preview_options}" \
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
        "${api_address}/bot${api_token}/sendMessage"
)"
then
    log_text="sendMessage (${update_id}): Failed to access Telegram Bot API"
    source "${units}/log.zsh"

    exit 0
fi

if ! jq -e '.' <<< "${output_data}" > /dev/null
then
    log_text="sendMessage (${update_id}): An unknown error occurred"
    source "${units}/log.zsh"

    exit 0
fi

if [[ "$(jq -r '.ok' <<< "${output_data}")" != "true" ]]
then
    error_description="$(jq -r '.description' <<< "${output_data}")"

    if [[ "${error_description}" != "null" ]]
    then
        log_text="sendMessage (${update_id}): ${error_description}"
    else
        log_text="sendMessage (${update_id}): An unknown error occurred"
    fi

    source "${units}/log.zsh"
fi
