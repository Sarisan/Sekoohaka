# Copyright (C) 2024-2026 Maria Lisina
# Copyright (C) 2024-2026 Danil Lisin
# SPDX-License-Identifier: Apache-2.0

if ! ib_auth_data="$(
    curl --connect-timeout ${connrefused_timeout} \
        --data-urlencode "username=${ib_login}" \
        --data-urlencode "api_key=${ib_key}" \
        --get \
        --max-time ${external_timeout} \
        --proxy "${external_proxy}" \
        --retry 1 \
        --retry-connrefused \
        --retry-max-time $((external_timeout - connrefused_timeout)) \
        --silent \
        --user-agent "${useragent}" \
        "${ib_auth}/user.json"
)"
then
    output_text="Failed to access ${ib_name} API"

    log_text="ib_auth (${update_id}): ${output_text}"
    source "${units}/log.zsh"

    return 0
fi

if ! jq -e '.' <<< "${ib_auth_data}" > /dev/null
then
    output_text="Invalid username or API key"
fi
