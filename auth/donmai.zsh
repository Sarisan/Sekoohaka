# Copyright (C) 2024-2025 Maria Lisina
# Copyright (C) 2024-2025 Danil Lisin
# SPDX-License-Identifier: Apache-2.0

if ! ib_auth_data="$(
    curl --connect-timeout ${connrefused_timeout} \
        --max-time ${external_timeout} \
        --proxy "${external_proxy}" \
        --request GET \
        --retry 1 \
        --retry-connrefused \
        --retry-max-time $((external_timeout - connrefused_timeout)) \
        --silent \
        --user "${ib_login}:${ib_key}" \
        --user-agent "${useragent}" \
        "${ib_auth}/profile.json"
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

if [[ "$(jq -r '.success' <<< "${ib_auth_data}")" == "false" ]]
then
    output_text="Error: <code>$(jq -r '.message' <<< "${ib_auth_data}" | htmlescape)</code>"
    return 0
fi

if [[ "$(jq -r '.name' <<< "${ib_auth_data}")" != "${ib_login}" ]]
then
    output_text="Failed to verify user authorization"
    return 0
fi

printf "%s" "${ib_login}:${ib_key}" | base64 > "${token_file}"
