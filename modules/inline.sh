# Copyright (C) 2024-2025 Maria Lisina
# Copyright (C) 2024-2025 Danil Lisin
# SPDX-License-Identifier: Apache-2.0

set -- $(jq -r '.inline_query.query' "${update}")

if [ "${1}" = "null" ]
then
    exit 0
fi

command="${1}"

user_id="$(jq -r '.inline_query.from.id' "${update}")"
query_id="$(jq -r '.inline_query.id' "${update}")"
chat_type="$(jq -r '.inline_query.chat_type' "${update}")"
offset="$(jq -r '.inline_query.offset' "${update}")"

. "${units}/user.sh"

if [ -n "${command}" ]
then
    shift
else
    . "${submodules}/inline_none.sh"
fi

case "${command}" in
    ("donate")
        . "${submodules}/inline_donate.sh"
    ;;
    ("help")
        . "${submodules}/inline_help.sh"
    ;;
    ("original")
        . "${submodules}/inline_original.sh"
    ;;
    ("post")
        . "${submodules}/inline_post.sh"
    ;;
    ("short")
        . "${submodules}/inline_short.sh"
    ;;
    ("shorts" | s)
        . "${submodules}/inline_shorts.sh"
    ;;
    (*)
        . "${submodules}/inline_search.sh"
    ;;
esac

output_file="${cache}/${update_id}_answerInlineQuery.json"
dump="${dump} ${output_file##*/}"

if ! curl --data-urlencode "inline_query_id=${query_id}" \
    --data-urlencode "results=${results}" \
    --data-urlencode "cache_time=0" \
    --data-urlencode "next_offset=${next_offset}" \
    --get \
    --max-time ${internal_timeout} \
    --output "${output_file}" \
    --proxy "${internal_proxy}" \
    --silent \
    "${api_address}/bot${api_token}/answerInlineQuery"
then
    log_text="answerInlineQuery (${update_id}): Failed to access Telegram Bot API"

    . "${units}/log.sh"
    . "${units}/dump.sh"

    exit 0
fi

if ! jq -e '.' "${output_file}" > /dev/null
then
    log_text="answerInlineQuery (${update_id}): An unknown error occurred"

    . "${units}/log.sh"
    . "${units}/dump.sh"

    exit 0
fi

if [ "$(jq -r '.ok' "${output_file}")" != "true" ]
then
    error_description="$(jq -r '.description' "${output_file}")"

    if [ "${error_description}" != "null" ]
    then
        log_text="answerInlineQuery (${update_id}): ${error_description}"
    else
        log_text="answerInlineQuery (${update_id}): An unknown error occurred"
    fi

    . "${units}/log.sh"
    . "${units}/dump.sh"
fi
