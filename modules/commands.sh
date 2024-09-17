# Copyright (C) 2024 Maria Lisina
# Copyright (C) 2024 Danil Lisin
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
message_thread_id="$(jq -r '.message.message_thread_id' "${update}")"

reply_parameters="$(jq --null-input --compact-output \
    --arg message_id "${message_id}" \
    '{"message_id": $message_id, "allow_sending_without_reply": true}')"

if [ "${message_thread_id}" = "null" ]
then
    unset message_thread_id
fi

case "${command}" in
    ("/authorize" | "/authorize@${username}")
        . "${submodules}/command_authorize.sh"
    ;;
    ("/help" | "/help@${username}")
        . "${submodules}/command_help.sh"
    ;;
    ("/original" | "/original@${username}")
        . "${submodules}/command_original.sh"
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
    ("/start" | "/start@${username}")
        . "${submodules}/command_help.sh"
    ;;
    ("/stop" | "/stop@${username}")
        . "${submodules}/command_stop.sh"
    ;;
    (*)
        exit 0
    ;;
esac

curl --data-urlencode "chat_id=${chat_id}" \
    --data-urlencode "message_thread_id=${message_thread_id}" \
    --data-urlencode "text=${output_text}" \
    --data-urlencode "parse_mode=HTML" \
    --data-urlencode "link_preview_options=${link_preview_options}" \
    --data-urlencode "reply_parameters=${reply_parameters}" \
    --data-urlencode "reply_markup=${reply_markup}" \
    --get \
    --proxy "${internal}" \
    --silent \
    "${address}/bot${token}/sendMessage" > /dev/null