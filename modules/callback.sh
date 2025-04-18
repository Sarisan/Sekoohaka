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
    dump="${dump} ${output_file##*/}"

    if ! curl --data-urlencode "chat_id=${chat_id}" \
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
        --user-agent "${useragent}" \
        "${api_address}/bot${api_token}/editMessageText"
    then
        notification_text="Failed to update message"
        log_text="editMessageText (${update_id}): Failed to access Telegram Bot API"

        . "${units}/log.sh"
        . "${units}/dump.sh"
    fi

    if [ -z "${notification_text}" ] && ! jq -e '.' "${output_file}" > /dev/null
    then
        notification_text="An unknown error occurred"
        log_text="editMessageText (${update_id}): An unknown error occurred"

        . "${units}/log.sh"
        . "${units}/dump.sh"
    fi

    if [ -z "${notification_text}" ] && [ "$(jq -r '.ok' "${output_file}")" != "true" ]
    then
        notification_text="Failed to update message"
        error_description="$(jq -r '.description' "${output_file}")"

        if [ "${error_description}" != "null" ]
        then
            log_text="editMessageText (${update_id}): ${error_description}"
        else
            log_text="editMessageText (${update_id}): An unknown error occurred"
        fi

        . "${units}/log.sh"
        . "${units}/dump.sh"
    fi
fi

output_file="${cache}/${update_id}_answerCallbackQuery.json"
dump="${dump} ${output_file##*/}"

if ! curl --data-urlencode "callback_query_id=${query_id}" \
    --data-urlencode "text=${notification_text}" \
    --data-urlencode "cache_time=0" \
    --get \
    --max-time ${internal_timeout} \
    --output "${output_file}" \
    --proxy "${internal_proxy}" \
    --silent \
    --user-agent "${useragent}" \
    "${api_address}/bot${api_token}/answerCallbackQuery"
then
    log_text="answerCallbackQuery (${update_id}): Failed to access Telegram Bot API"

    . "${units}/log.sh"
    . "${units}/dump.sh"

    exit 0
fi

if ! jq -e '.' "${output_file}" > /dev/null
then
    log_text="answerCallbackQuery (${update_id}): An unknown error occurred"

    . "${units}/log.sh"
    . "${units}/dump.sh"

    exit 0
fi

if [ "$(jq -r '.ok' "${output_file}")" != "true" ]
then
    error_description="$(jq -r '.description' "${output_file}")"

    if [ "${error_description}" != "null" ]
    then
        log_text="answerCallbackQuery (${update_id}): ${error_description}"
    else
        log_text="answerCallbackQuery (${update_id}): An unknown error occurred"
    fi

    . "${units}/log.sh"
    . "${units}/dump.sh"
fi
