# Copyright (C) 2024-2025 Maria Lisina
# Copyright (C) 2024-2025 Danil Lisin
# SPDX-License-Identifier: Apache-2.0

aliases="${files}/aliases.txt"
blacklist="${files}/blacklist.txt"
whitelist="${files}/whitelist.txt"

positional_parameters="${@}"

if [ -s "${aliases}" ] && alias="$(grep -x "${user_id} .*" "${aliases}")"
then
    user_id="$(printf "%s" "${alias}" | parameter 2)"
fi

if [ -s "${blacklist}" ] && grep -qx "${user_id}" "${blacklist}"
then
    exit 0
fi

if [ -s "${whitelist}" ] && ! grep -qx "${user_id}" "${whitelist}"
then
    exit 0
fi

set -- ${positional_parameters}
