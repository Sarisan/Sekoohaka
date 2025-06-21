# Copyright (C) 2024-2025 Maria Lisina
# Copyright (C) 2024-2025 Danil Lisin
# SPDX-License-Identifier: Apache-2.0

ib_auth_file="${cache}/${update_id}_profile.json"
dump+=(${ib_auth_file##*/})

if ! curl --connect-timeout ${connrefused_timeout} \
    --max-time ${external_timeout} \
    --output "${ib_auth_file}" \
    --proxy "${external_proxy}" \
    --request GET \
    --retry 1 \
    --retry-connrefused \
    --retry-max-time $((external_timeout - connrefused_timeout)) \
    --silent \
    --user "${ib_login}:${ib_key}" \
    --user-agent "${useragent}" \
    "${ib_auth}/profile.json"
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

if [[ "$(jq -r '.success' "${ib_auth_file}")" = "false" ]]
then
    output_text="Error: <code>$(jq -r '.message' "${ib_auth_file}" | htmlescape)</code>"
    log_text="ib_auth (${update_id}): Error: $(jq -r '.message' "${ib_auth_file}")"

    . "${units}/log.zsh"
    . "${units}/dump.zsh"

    return 0
fi

if [[ "$(jq -r '.name' "${ib_auth_file}")" != "${ib_login}" ]]
then
    output_text="Failed to verify user authorization"
    log_text="ib_auth (${update_id}): ${output_text}"

    . "${units}/log.zsh"
    . "${units}/dump.zsh"

    return 0
fi

printf "%s" "${ib_login}:${ib_key}" | base64 > "${token_file}"
