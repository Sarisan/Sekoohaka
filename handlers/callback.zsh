# Copyright (C) 2024-2026 Maria Lisina
# Copyright (C) 2024-2026 Danil Lisin
# SPDX-License-Identifier: Apache-2.0

callback_query=($(jq -r '.callback_query.data' <<< "${update}"))

if [[ "${callback_query}" == "null" ]]
then
    exit 0
fi

user_id="$(jq -r '.callback_query.from.id' <<< "${update}")"
query_id="$(jq -r '.callback_query.id' <<< "${update}")"

source "${units}/user.zsh"
set -- ${callback_query[@]}

command="${1}"
shift

case "${command}" in
    ("delete")
        source "${agents}/callback_delete.zsh"
    ;;
    ("post")
        source "${agents}/callback_post.zsh"
    ;;
    ("reset")
        source "${agents}/callback_reset.zsh"
    ;;
    ("short")
        source "${agents}/callback_short.zsh"
    ;;
    ("stop")
        source "${agents}/callback_stop.zsh"
    ;;
    ("tags")
        source "${agents}/callback_tags.zsh"
    ;;
    (*)
        exit 0
    ;;
esac

if [[ -z "${notification_text}" && -n "${output_text}" ]]
then
    chat_id="$(jq -r '.callback_query.message.chat.id' <<< "${update}")"
    message_id="$(jq -r '.callback_query.message.message_id' <<< "${update}")"
    inline_message_id="$(jq -r '.callback_query.inline_message_id' <<< "${update}")"

    if [[ "${inline_message_id}" != "null" ]]
    then
        unset chat_id
        unset message_id
    fi

    if ! output_data="$(
        curl --connect-timeout ${connrefused_timeout} \
            --data-urlencode "chat_id=${chat_id}" \
            --data-urlencode "message_id=${message_id}" \
            --data-urlencode "inline_message_id=${inline_message_id}" \
            --data-urlencode "text=${output_text}" \
            --data-urlencode "parse_mode=HTML" \
            --data-urlencode "link_preview_options=${link_preview_options}" \
            --data-urlencode "reply_markup=${reply_markup}" \
            --get \
            --max-time ${internal_timeout} \
            --proxy "${internal_proxy}" \
            --retry 1 \
            --retry-connrefused \
            --retry-max-time $((internal_timeout - connrefused_timeout)) \
            --silent \
            --user-agent "${useragent}" \
            "${api_address}/bot${api_token}/editMessageText"
    )"
    then
        notification_text="Failed to update message"

        log_text="editMessageText (${update_id}): Failed to access Telegram Bot API"
        source "${units}/log.zsh"
    fi

    if [[ -z "${notification_text}" ]] && ! jq -e '.' <<< "${output_data}" > /dev/null
    then
        notification_text="An unknown error occurred"

        log_text="editMessageText (${update_id}): An unknown error occurred"
        source "${units}/log.zsh"
    fi

    if [[ -z "${notification_text}" && "$(jq -r '.ok' <<< "${output_data}")" != "true" ]]
    then
        notification_text="Failed to update message"
        error_description="$(jq -r '.description' <<< "${output_data}")"

        if [[ "${error_description}" != "null" ]]
        then
            log_text="editMessageText (${update_id}): ${error_description}"
        else
            log_text="editMessageText (${update_id}): An unknown error occurred"
        fi

        source "${units}/log.zsh"
    fi
fi

if ! output_data="$(
    curl --connect-timeout ${connrefused_timeout} \
        --data-urlencode "callback_query_id=${query_id}" \
        --data-urlencode "text=${notification_text}" \
        --data-urlencode "cache_time=0" \
        --get \
        --max-time ${internal_timeout} \
        --proxy "${internal_proxy}" \
        --retry 1 \
        --retry-connrefused \
        --retry-max-time $((internal_timeout - connrefused_timeout)) \
        --silent \
        --user-agent "${useragent}" \
        "${api_address}/bot${api_token}/answerCallbackQuery"
)"
then
    log_text="answerCallbackQuery (${update_id}): Failed to access Telegram Bot API"
    source "${units}/log.zsh"

    exit 0
fi

if ! jq -e '.' <<< "${output_data}" > /dev/null
then
    log_text="answerCallbackQuery (${update_id}): An unknown error occurred"
    source "${units}/log.zsh"

    exit 0
fi

if [[ "$(jq -r '.ok' <<< "${output_data}")" != "true" ]]
then
    error_description="$(jq -r '.description' <<< "${output_data}")"

    if [[ "${error_description}" != "null" ]]
    then
        log_text="answerCallbackQuery (${update_id}): ${error_description}"
    else
        log_text="answerCallbackQuery (${update_id}): An unknown error occurred"
    fi

    source "${units}/log.zsh"
fi
