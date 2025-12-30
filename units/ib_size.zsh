# Copyright (C) 2024-2026 Maria Lisina
# Copyright (C) 2024-2026 Danil Lisin
# SPDX-License-Identifier: Apache-2.0

if [[ -n "${ib_file_size}" && "${ib_file_size}" != "null" ]]
then
    return
fi

if [[ -z "${ib_file_url}" || "${ib_file_url}" == "null" ]]
then
    return
fi

ib_file_size="$(
    curl --connect-timeout ${connrefused_timeout} \
        --head \
        --max-time ${head_timeout} \
        --proxy "${external_proxy}" \
        --retry 1 \
        --retry-connrefused \
        --retry-max-time $((external_timeout - connrefused_timeout)) \
        --silent \
        --user-agent "${useragent}" \
        "${ib_file_url}" |
    grep -i "content-length" |
    cut -d ' ' -f 2 |
    tr -d '\r'
)"
