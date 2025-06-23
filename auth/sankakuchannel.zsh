# Copyright (C) 2024-2025 Maria Lisina
# Copyright (C) 2024-2025 Danil Lisin
# SPDX-License-Identifier: Apache-2.0

ib_login_data="$(
    jq --null-input --compact-output \
        --arg login "${ib_login}" \
        --arg password "${ib_key}" \
        '{"login": $login, "password": $password}'
)"

ib_auth_file="${cache}/${update_id}_token.json"
dump+=(${ib_auth_file##*/})

if ! curl --connect-timeout ${connrefused_timeout} \
    --data "${ib_login_data}" \
    --header "Content-Type: application/json" \
    --max-time ${external_timeout} \
    --output "${ib_auth_file}" \
    --proxy "${external_proxy}" \
    --request POST \
    --retry 1 \
    --retry-connrefused \
    --retry-max-time $((external_timeout - connrefused_timeout)) \
    --silent \
    --user-agent "${useragent}" \
    "${ib_auth}/auth/token"
then
    output_text="Failed to access ${ib_name} API"
    log_text="ib_auth (${update_id}): ${output_text}"

    . "${units}/log.zsh"
    . "${units}/dump.zsh"

    return 0
fi

if ! jq -e '.' "${ib_auth_file}" > /dev/null
then
    output_text="An unknown error occurred"
    log_text="ib_auth (${update_id}): ${output_text}"

    . "${units}/log.zsh"
    . "${units}/dump.zsh"

    return 0
fi

if [[ "$(jq -r '.success' "${ib_auth_file}")" != "true" ]]
then
    output_text="Error: <code>$(jq -r '.error' "${ib_auth_file}" | htmlescape)</code>"
    log_text="ib_auth (${update_id}): Error: $(jq -r '.error' "${ib_auth_file}")"

    . "${units}/log.zsh"
    . "${units}/dump.zsh"

    return 0
fi

jq -r '.access_token' "${ib_auth_file}" > "${token_file}"
strftime %s > "${timestamp_file}"
