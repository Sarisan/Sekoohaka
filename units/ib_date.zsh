# Copyright (C) 2024-2025 Maria Lisina
# Copyright (C) 2024-2025 Danil Lisin
# SPDX-License-Identifier: Apache-2.0

if [[ -n "${ib_created_at}" && "${ib_created_at}" != "null" ]]
then
    if [[ -n "${ib_itzfield}" ]]
    then
        ib_created_at="$(printf "%s" "${ib_created_at}" | parameter ${ib_itzfield})"
    fi

    if [[ -n "${ib_idate}" ]]
    then
        ib_date_text="$(date -ud "${ib_created_at}" -D "${ib_idate}" +"%Y-%m-%d %H:%M")"
    else
        ib_date_text="$(date -ud "@${ib_created_at}" +"%Y-%m-%d %H:%M")"
    fi
fi
