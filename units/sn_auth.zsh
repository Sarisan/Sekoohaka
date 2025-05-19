# Copyright (C) 2024-2025 Maria Lisina
# Copyright (C) 2024-2025 Danil Lisin
# SPDX-License-Identifier: Apache-2.0

if [[ -n "${1}" ]]
then
    sn_key="${1}"
elif [[ -f "${user_config}/saucenao" ]]
then
    sn_key="$(cat "${user_config}/saucenao")"
    return 0
else
    output_text="You must provide your SauceNAO API Key before you can use SauceNAO"
    return 0
fi

sn_file="${cache}/${update_id}_search.json"
dump="${dump} ${sn_file##*/}"

if ! curl --data-urlencode "output_type=2" \
    --data-urlencode "api_key=${sn_key}" \
    --get \
    --max-time ${external_timeout} \
    --output "${sn_file}" \
    --proxy "${external_proxy}" \
    --silent \
    --user-agent "${useragent}" \
    "https://saucenao.com/search.php"
then
    output_text="Failed to process request"
    log_text="sn_auth (${update_id}): ${output_text}"

    . "${units}/log.zsh"
    . "${units}/dump.zsh"

    return 0
fi

if ! jq -e '.' "${sn_file}" > /dev/null
then
    output_text="An unknown error occurred"
    log_text="sn_auth (${update_id}): ${output_text}"

    . "${units}/log.zsh"
    . "${units}/dump.zsh"

    return 0
fi

if [[ "$(jq -r '.header.user_id' "${sn_file}")" = "null" ]]
then
    output_text="Invalid API Key"
    log_text="sn_auth (${update_id}): ${output_text}"

    . "${units}/log.zsh"
    . "${units}/dump.zsh"

    return 0
fi

output_text="Authorized successfully"
printf "%s\n" "${sn_key}" > "${user_config}/saucenao"
