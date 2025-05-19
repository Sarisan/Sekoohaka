# Copyright (C) 2024-2025 Maria Lisina
# Copyright (C) 2024-2025 Danil Lisin
# SPDX-License-Identifier: Apache-2.0

sn_file="${cache}/${update_id}_search.json"
dump=(${dump[@]} ${sn_file##*/})

if ! curl --form "output_type=2" \
    --form "api_key=${sn_key}" \
    --form "dbs[]=9" \
    --form "dbs[]=12" \
    --form "dbs[]=25" \
    --form "dbs[]=26" \
    --form "dbs[]=27" \
    --form "dbs[]=30" \
    --form "dedupe=2" \
    --form "${sn_query}" \
    --get \
    --max-time ${external_timeout} \
    --output "${sn_file}" \
    --proxy "${external_proxy}" \
    --silent \
    --user-agent "${useragent}" \
    "https://saucenao.com/search.php"
then
    output_text="Failed to process request"
    log_text="sn_search (${update_id}): ${output_text}"

    . "${units}/log.zsh"
    . "${units}/dump.zsh"

    return 0
fi

if ! jq -e '.' "${sn_file}" > /dev/null
then
    output_text="An unknown error occurred"
    log_text="sn_search (${update_id}): ${output_text}"

    . "${units}/log.zsh"
    . "${units}/dump.zsh"

    return 0
fi

if [[ "$(jq -r '.header.status' "${sn_file}")" != "0" ]]
then
    output_text="Error: <code>$(jq -r '.header.message' "${sn_file}" | htmlescape)</code>"
    log_text="sn_search (${update_id}): $(jq -r '.header.message' "${sn_file}")"

    . "${units}/log.zsh"
    . "${units}/dump.zsh"
fi
