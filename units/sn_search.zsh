# Copyright (C) 2024-2026 Maria Lisina
# Copyright (C) 2024-2026 Danil Lisin
# SPDX-License-Identifier: Apache-2.0

if ! sn_data="$(
    curl --connect-timeout ${connrefused_timeout} \
        --form "output_type=2" \
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
        --proxy "${external_proxy}" \
        --retry 1 \
        --retry-connrefused \
        --retry-max-time $((external_timeout - connrefused_timeout)) \
        --silent \
        --user-agent "${useragent}" \
        "https://saucenao.com/search.php"
)"
then
    output_text="Failed to access SauceNAO API"

    log_text="sn_search (${update_id}): ${output_text}"
    source "${units}/log.zsh"

    return 0
fi

if ! jq -e '.' <<< "${sn_data}" > /dev/null
then
    output_text="An unknown error occurred"

    log_text="sn_search (${update_id}): ${output_text}"
    source "${units}/log.zsh"

    return 0
fi

sn_status="$(jq -r '.header.status' <<< "${sn_data}")"

case "${sn_status}" in
    (-2)
        output_text="Rate limit exceeded, try again later"
    ;;
    (-1)
        output_text="Invalid API key"
    ;;
    (0)
    ;;
    (*)
        output_text="An unknown error occurred"
    ;;
esac
