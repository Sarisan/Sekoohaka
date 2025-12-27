# Copyright (C) 2024-2025 Maria Lisina
# Copyright (C) 2024-2025 Danil Lisin
# SPDX-License-Identifier: Apache-2.0

ib_login_data="$(
    jq --null-input --compact-output \
        --arg login "${ib_login}" \
        --arg password "${ib_key}" \
        '{"login": $login, "password": $password}'
)"

if ! ib_auth_data="$(
    curl --connect-timeout ${connrefused_timeout} \
        --data "${ib_login_data}" \
        --header "Content-Type: application/json" \
        --max-time ${external_timeout} \
        --proxy "${external_proxy}" \
        --request POST \
        --retry 1 \
        --retry-connrefused \
        --retry-max-time $((external_timeout - connrefused_timeout)) \
        --silent \
        --user-agent "${useragent}" \
        "${ib_auth}/auth/token"
)"
then
    output_text="Failed to access ${ib_name} API"

    log_text="ib_auth (${update_id}): ${output_text}"
    source "${units}/log.zsh"

    return 0
fi

if ! jq -e '.' <<< "${ib_auth_data}" > /dev/null
then
    output_text="An unknown error occurred"

    log_text="ib_auth (${update_id}): ${output_text}"
    source "${units}/log.zsh"

    return 0
fi

if [[ "$(jq -r '.success' <<< "${ib_auth_data}")" != "true" ]]
then
    output_text="Error: <code>$(jq -r '.error' <<< "${ib_auth_data}" | htmlescape)</code>"
    return 0
fi

jq -r '.access_token' <<< "${ib_auth_data}" > "${token_file}"
strftime %s > "${timestamp_file}"
