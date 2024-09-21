# Copyright (C) 2024 Maria Lisina
# Copyright (C) 2024 Danil Lisin
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

if [ -n "${command}" ]
then
    shift
else
    . "${submodules}/inline_none.sh"
fi

case "${command}" in
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

curl --data-urlencode "inline_query_id=${query_id}" \
    --data-urlencode "results=${results}" \
    --data-urlencode "cache_time=0" \
    --data-urlencode "next_offset=${next_offset}" \
    --get \
    --proxy "${internal}" \
    --silent \
    "${address}/bot${token}/answerInlineQuery" > /dev/null
