# Copyright (C) 2024-2025 Maria Lisina
# Copyright (C) 2024-2025 Danil Lisin
# SPDX-License-Identifier: Apache-2.0

set -- $(jq -r '.callback_query.data' "${update}")

if [ "${1}" = "null" ]
then
    exit 0
fi

command="${1}"
shift

user_id="$(jq -r '.callback_query.from.id' "${update}")"
query_id="$(jq -r '.callback_query.id' "${update}")"

. "${units}/user.sh"

case "${command}" in
    ("post")
        . "${submodules}/callback_post.sh"
    ;;
    ("reset")
        . "${submodules}/callback_reset.sh"
    ;;
    ("short")
        . "${submodules}/callback_short.sh"
    ;;
    ("stop")
        . "${submodules}/callback_stop.sh"
    ;;
    ("tags")
        . "${submodules}/callback_tags.sh"
    ;;
    (*)
        exit 0
    ;;
esac

if [ -z "${notification_text}" ] && [ -n "${output_text}" ]
then
    chat_id="$(jq -r '.callback_query.message.chat.id' "${update}")"
    message_id="$(jq -r '.callback_query.message.message_id' "${update}")"
    inline_message_id="$(jq -r '.callback_query.inline_message_id' "${update}")"

    if [ "${inline_message_id}" != "null" ]
    then
        unset chat_id
        unset message_id
    fi

    output_file="${cache}/${update_id}_editMessageText.json"

    curl --data-urlencode "chat_id=${chat_id}" \
        --data-urlencode "message_id=${message_id}" \
        --data-urlencode "inline_message_id=${inline_message_id}" \
        --data-urlencode "text=${output_text}" \
        --data-urlencode "parse_mode=HTML" \
        --data-urlencode "link_preview_options=${link_preview_options}" \
        --data-urlencode "reply_markup=${reply_markup}" \
        --get \
        --max-time ${internal_timeout} \
        --output "${output_file}" \
        --proxy "${internal_proxy}" \
        --silent \
        "${api_address}/bot${api_token}/editMessageText"

    if [ -z "${notification_text}" ] && ! jq -e '.' "${output_file}" > /dev/null 2>&1
    then
        notification_text="An unknown error occurred"
    fi

    if [ -z "${notification_text}" ] && [ "$(jq -r '.ok' "${output_file}")" != "true" ]
    then
        notification_text="Failed to update message"
    fi
fi

curl --data-urlencode "callback_query_id=${query_id}" \
    --data-urlencode "text=${notification_text}" \
    --data-urlencode "cache_time=0" \
    --get \
    --max-time ${internal_timeout} \
    --proxy "${internal_proxy}" \
    --silent \
    "${api_address}/bot${api_token}/answerCallbackQuery" > /dev/null
