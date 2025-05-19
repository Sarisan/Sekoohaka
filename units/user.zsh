# Copyright (C) 2024-2025 Maria Lisina
# Copyright (C) 2024-2025 Danil Lisin
# SPDX-License-Identifier: Apache-2.0

aliases_file="${files}/aliases.txt"
blacklist_file="${files}/blacklist.txt"
whitelist_file="${files}/whitelist.txt"

if [[ -s "${aliases_file}" ]] && alias="$(grep -x "${user_id} .*" "${aliases_file}")"
then
    user_id="$(printf "%s" "${alias}" | parameter 2)"
fi

if [[ -s "${blacklist_file}" ]] && grep -qx "${user_id}" "${blacklist_file}"
then
    exit 0
fi

if [[ -s "${whitelist_file}" ]] && ! grep -qx "${user_id}" "${whitelist_file}"
then
    exit 0
fi

user_config="${config}/${user_id}"
