# Copyright (C) 2024-2025 Maria Lisina
# Copyright (C) 2024-2025 Danil Lisin
# SPDX-License-Identifier: Apache-2.0

ib_auth_file="${cache}/${update_id}_user.json"
dump+=(${ib_auth_file##*/})

if ! curl --connect-timeout ${connrefused_timeout} \
    --data-urlencode "username=${ib_login}" \
    --data-urlencode "api_key=${ib_key}" \
    --get \
    --max-time ${external_timeout} \
    --output "${ib_auth_file}" \
    --proxy "${external_proxy}" \
    --retry 1 \
    --retry-connrefused \
    --retry-max-time $((external_timeout - connrefused_timeout)) \
    --silent \
    --user-agent "${useragent}" \
    "${ib_auth}/user.json"
then
    output_text="Failed to access ${ib_name} API"
    log_text="ib_auth (${update_id}): ${output_text}"

    . "${units}/log.zsh"
    . "${units}/dump.zsh"

    return 0
fi

if ! jq -e '.' "${ib_auth_file}" > /dev/null
then
    output_text="Invalid username or API key"
    log_text="ib_auth (${update_id}): ${output_text}"

    . "${units}/log.zsh"
    . "${units}/dump.zsh"

    return 0
fi
