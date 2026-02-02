# Copyright (C) 2024-2026 Maria Lisina
# Copyright (C) 2024-2026 Danil Lisin
# SPDX-License-Identifier: Apache-2.0

command_query=($(jq -r '.message.text' <<< "${update}"))

if [[ "${command_query}" == "null" ]]
then
    exit 0
fi

user_id="$(jq -r '.message.from.id' <<< "${update}")"
chat_id="$(jq -r '.message.chat.id' <<< "${update}")"
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
set -- ${command_query[@]}

command="${1}"
shift

case "${command}" in
    ("/authorize" | "/authorize@${username}")
        source "${agents}/command_authorize.zsh"
    ;;
    ("/donate" | "/donate@${username}")
        source "${agents}/command_donate.zsh"
    ;;
    ("/export" | "/export@${username}")
        source "${agents}/command_export.zsh"
    ;;
    ("/hash" | "/hash@${username}")
        source "${agents}/command_hash.zsh"
    ;;
    ("/help" | "/help@${username}")
        source "${agents}/command_help.zsh"
    ;;
    ("/original" | "/original@${username}")
        source "${agents}/command_original.zsh"
    ;;
    ("/ping" | "/ping@${username}")
        source "${agents}/command_ping.zsh"
    ;;
    ("/post" | "/post@${username}")
        source "${agents}/command_post.zsh"
    ;;
    ("/prpr" | "/prpr@${username}")
        source "${agents}/command_prpr.zsh"
    ;;
    ("/short" | "/short@${username}")
        source "${agents}/command_short.zsh"
    ;;
    ("/shorts" | "/shorts@${username}")
        source "${agents}/command_shorts.zsh"
    ;;
    ("/source" | "/source@${username}")
        source "${agents}/command_source.zsh"
    ;;
    ("/start" | "/start@${username}")
        source "${agents}/command_help.zsh"
    ;;
    ("/stop" | "/stop@${username}")
        source "${agents}/command_stop.zsh"
    ;;
    (*)
        source "${agents}/url_parser.zsh"
    ;;
esac

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
