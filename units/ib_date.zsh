# Copyright (C) 2024-2026 Maria Lisina
# Copyright (C) 2024-2026 Danil Lisin
# SPDX-License-Identifier: Apache-2.0

if [[ -n "${ib_created_at}" && "${ib_created_at}" != "null" ]]
then
    if [[ -n "${ib_idate}" ]]
    then
        ib_created_at="$(strftime -r "${ib_idate}" "${ib_created_at}")"
    fi

    ib_date_text="$(strftime "%Y-%m-%d %H:%M" "${ib_created_at}")"
fi
