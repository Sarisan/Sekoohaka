# Copyright (C) 2024-2026 Maria Lisina
# Copyright (C) 2024-2026 Danil Lisin
# SPDX-License-Identifier: Apache-2.0

if [[ -n "${1}" ]]
then
    sn_key="${1}"
elif [[ -f "${user_config}/saucenao" ]]
then
    sn_key="$(< "${user_config}/saucenao")"
    return
elif [[ -f "${default_user_config}/saucenao" ]]
then
    sn_key="$(< "${default_user_config}/saucenao")"
    return
else
    output_text="You must provide your SauceNAO API key before you can use SauceNAO"
    return
fi

if ! mkdir -p "${user_config}"
then
    output_text="Failed to create user config"

    log_text="sn_auth (${update_id}): ${output_text}"
    source "${units}/log.zsh"

    return
fi

if ! sn_data="$(
    curl --connect-timeout ${connrefused_timeout} \
        --data-urlencode "output_type=2" \
        --data-urlencode "api_key=${sn_key}" \
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

    log_text="sn_auth (${update_id}): ${output_text}"
    source "${units}/log.zsh"

    return
fi

if ! jq -e '.' <<< "${sn_data}" > /dev/null
then
    output_text="An unknown error occurred"

    log_text="sn_auth (${update_id}): ${output_text}"
    source "${units}/log.zsh"

    return
fi

sn_status="$(jq -r '.header.status' <<< "${sn_data}")"

case "${sn_status}" in
    (-3)
        output_text="Authorized successfully"
        printf "%s\n" "${sn_key}" > "${user_config}/saucenao"
    ;;
    (-2)
        output_text="Rate limit exceeded, try again later"
    ;;
    (-1)
        output_text="Invalid API key"
    ;;
    (*)
        output_text="An unknown error occurred"
    ;;
esac
