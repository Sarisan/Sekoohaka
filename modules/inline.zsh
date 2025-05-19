# Copyright (C) 2024-2025 Maria Lisina
# Copyright (C) 2024-2025 Danil Lisin
# SPDX-License-Identifier: Apache-2.0

inline_query=($(jq -r '.inline_query.query' "${update}"))

if [[ "${inline_query}" = "null" ]]
then
    exit 0
fi

user_id="$(jq -r '.inline_query.from.id' "${update}")"
query_id="$(jq -r '.inline_query.id' "${update}")"
chat_type="$(jq -r '.inline_query.chat_type' "${update}")"
offset="$(jq -r '.inline_query.offset' "${update}")"

. "${units}/user.zsh"
set -- ${inline_query[@]}

command="${1}"

if [[ -n "${command}" ]]
then
    shift
else
    . "${submods}/inline_none.zsh"
fi

case "${command}" in
    ("donate")
        . "${submods}/inline_donate.zsh"
    ;;
    ("help")
        . "${submods}/inline_help.zsh"
    ;;
    ("original")
        . "${submods}/inline_original.zsh"
    ;;
    ("post")
        . "${submods}/inline_post.zsh"
    ;;
    ("short")
        . "${submods}/inline_short.zsh"
    ;;
    ("shorts" | s)
        . "${submods}/inline_shorts.zsh"
    ;;
    (*)
        . "${submods}/inline_search.zsh"
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
    --user-agent "${useragent}" \
    "${api_address}/bot${api_token}/answerInlineQuery"
then
    log_text="answerInlineQuery (${update_id}): Failed to access Telegram Bot API"

    . "${units}/log.zsh"
    . "${units}/dump.zsh"

    exit 0
fi

if ! jq -e '.' "${output_file}" > /dev/null
then
    log_text="answerInlineQuery (${update_id}): An unknown error occurred"

    . "${units}/log.zsh"
    . "${units}/dump.zsh"

    exit 0
fi

if [[ "$(jq -r '.ok' "${output_file}")" != "true" ]]
then
    error_description="$(jq -r '.description' "${output_file}")"

    if [[ "${error_description}" != "null" ]]
    then
        log_text="answerInlineQuery (${update_id}): ${error_description}"
    else
        log_text="answerInlineQuery (${update_id}): An unknown error occurred"
    fi

    . "${units}/log.zsh"
    . "${units}/dump.zsh"
fi
