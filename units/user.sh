# Copyright (C) 2024 Maria Lisina
# Copyright (C) 2024 Danil Lisin
# SPDX-License-Identifier: Apache-2.0

aliases="${lists}/aliases"
blacklist="${lists}/blacklist"
whitelist="${lists}/whitelist"

positional_saved="${@}"

if [ -s "${aliases}" ]
then
    set -- $(cat "${aliases}")

    while [ ${#} -ge 2 ]
    do
        if [ "${user_id}" = "${1}" ]
        then
            user_id="${2}"
            break
        fi

        shift 2
    done
fi

if [ -s "${blacklist}" ] && grep -qw "${user_id}" "${blacklist}"
then
    exit 0
fi

if [ -s "${whitelist}" ] && ! grep -qw "${user_id}" "${whitelist}"
then
    exit 0
fi

set -- ${positional_saved}
