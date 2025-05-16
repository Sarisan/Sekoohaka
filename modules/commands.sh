# Copyright (C) 2024-2025 Maria Lisina
# Copyright (C) 2024-2025 Danil Lisin
# SPDX-License-Identifier: Apache-2.0

set -- $(jq -r '.message.text' "${update}")

if [ "${1}" = "null" ]
then
    exit 0
fi

command="${1}"
shift

user_id="$(jq -r '.message.from.id' "${update}")"
chat_id="$(jq -r '.message.chat.id' "${update}")"
message_id="$(jq -r '.message.message_id' "${update}")"
is_topic="$(jq -r '.message.is_topic_message' "${update}")"
message_thread_id="$(jq -r '.message.message_thread_id' "${update}")"

. "${units}/user.sh"

reply_parameters="$(jq --null-input --compact-output \
    --arg message_id "${message_id}" \
    '{"message_id": $message_id, "allow_sending_without_reply": true}')"

if [ "${is_topic}" = "null" ]
then
    unset message_thread_id
fi

case "${command}" in
    ("/authorize" | "/authorize@${username}")
        . "${submodules}/command_authorize.sh"
    ;;
    ("/donate" | "/donate@${username}")
        . "${submodules}/command_donate.sh"
    ;;
    ("/hash" | "/hash@${username}")
        . "${submodules}/command_hash.sh"
    ;;
    ("/help" | "/help@${username}")
        . "${submodules}/command_help.sh"
    ;;
    ("/original" | "/original@${username}")
        . "${submodules}/command_original.sh"
    ;;
    ("/ping" | "/ping@${username}")
        . "${submodules}/command_ping.sh"
    ;;
    ("/post" | "/post@${username}")
        . "${submodules}/command_post.sh"
    ;;
    ("/prpr" | "/prpr@${username}")
        . "${submodules}/command_prpr.sh"
    ;;
    ("/short" | "/short@${username}")
        . "${submodules}/command_short.sh"
    ;;
    ("/shorts" | "/shorts@${username}")
        . "${submodules}/command_shorts.sh"
    ;;
    ("/source" | "/source@${username}")
        . "${submodules}/command_source.sh"
    ;;
    ("/start" | "/start@${username}")
        . "${submodules}/command_help.sh"
    ;;
    ("/stop" | "/stop@${username}")
        . "${submodules}/command_stop.sh"
    ;;
    (*)
        . "${submodules}/url_parser.sh"
    ;;
esac

output_file="${cache}/${update_id}_sendMessage.json"
dump="${dump} ${output_file##*/}"

if ! curl --data-urlencode "chat_id=${chat_id}" \
    --data-urlencode "message_thread_id=${message_thread_id}" \
    --data-urlencode "text=${output_text}" \
    --data-urlencode "parse_mode=HTML" \
    --data-urlencode "link_preview_options=${link_preview_options}" \
    --data-urlencode "reply_parameters=${reply_parameters}" \
    --data-urlencode "reply_markup=${reply_markup}" \
    --get \
    --max-time ${internal_timeout} \
    --output "${output_file}" \
    --proxy "${internal_proxy}" \
    --silent \
    --user-agent "${useragent}" \
    "${api_address}/bot${api_token}/sendMessage"
then
    log_text="sendMessage (${update_id}): Failed to access Telegram Bot API"

    . "${units}/log.sh"
    . "${units}/dump.sh"

    exit 0
fi

if ! jq -e '.' "${output_file}" > /dev/null
then
    log_text="sendMessage (${update_id}): An unknown error occurred"

    . "${units}/log.sh"
    . "${units}/dump.sh"

    exit 0
fi

if [ "$(jq -r '.ok' "${output_file}")" != "true" ]
then
    error_description="$(jq -r '.description' "${output_file}")"

    if [ "${error_description}" != "null" ]
    then
        log_text="sendMessage (${update_id}): ${error_description}"
    else
        log_text="sendMessage (${update_id}): An unknown error occurred"
    fi

    . "${units}/log.sh"
    . "${units}/dump.sh"
fi
