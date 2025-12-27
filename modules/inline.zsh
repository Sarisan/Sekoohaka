# Copyright (C) 2024-2026 Maria Lisina
# Copyright (C) 2024-2026 Danil Lisin
# SPDX-License-Identifier: Apache-2.0

inline_query=($(jq -r '.inline_query.query' <<< "${update}"))

if [[ "${inline_query}" == "null" ]]
then
    exit 0
fi

user_id="$(jq -r '.inline_query.from.id' <<< "${update}")"
query_id="$(jq -r '.inline_query.id' <<< "${update}")"
chat_type="$(jq -r '.inline_query.chat_type' <<< "${update}")"
offset="$(jq -r '.inline_query.offset' <<< "${update}")"

source "${units}/user.zsh"
set -- ${inline_query[@]}

command="${1}"

if [[ -n "${command}" ]]
then
    shift
else
    source "${submods}/inline_none.zsh"
fi

case "${command}" in
    ("donate")
        source "${submods}/inline_donate.zsh"
    ;;
    ("help")
        source "${submods}/inline_help.zsh"
    ;;
    ("original")
        source "${submods}/inline_original.zsh"
    ;;
    ("post")
        source "${submods}/inline_post.zsh"
    ;;
    ("short")
        source "${submods}/inline_short.zsh"
    ;;
    ("shorts" | s)
        source "${submods}/inline_shorts.zsh"
    ;;
    (*)
        source "${submods}/inline_search.zsh"
    ;;
esac

if ! output_data="$(
    curl --connect-timeout ${connrefused_timeout} \
        --data-urlencode "inline_query_id=${query_id}" \
        --data-urlencode "results=${results}" \
        --data-urlencode "cache_time=0" \
        --data-urlencode "next_offset=${next_offset}" \
        --get \
        --max-time ${internal_timeout} \
        --proxy "${internal_proxy}" \
        --retry 1 \
        --retry-connrefused \
        --retry-max-time $((internal_timeout - connrefused_timeout)) \
        --silent \
        --user-agent "${useragent}" \
        "${api_address}/bot${api_token}/answerInlineQuery"
)"
then
    log_text="answerInlineQuery (${update_id}): Failed to access Telegram Bot API"
    source "${units}/log.zsh"

    exit 0
fi

if ! jq -e '.' <<< "${output_data}" > /dev/null
then
    log_text="answerInlineQuery (${update_id}): An unknown error occurred"
    source "${units}/log.zsh"

    exit 0
fi

if [[ "$(jq -r '.ok' <<< "${output_data}")" != "true" ]]
then
    error_description="$(jq -r '.description' <<< "${output_data}")"

    if [[ "${error_description}" != "null" ]]
    then
        log_text="answerInlineQuery (${update_id}): ${error_description}"
    else
        log_text="answerInlineQuery (${update_id}): An unknown error occurred"
    fi

    source "${units}/log.zsh"
fi
