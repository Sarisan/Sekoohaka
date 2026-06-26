# Copyright (C) 2024-2026 Maria Lisina
# Copyright (C) 2024-2026 Danil Lisin
# SPDX-License-Identifier: Apache-2.0

aliases_list="${files}/aliases.txt"
blacklist_list="${files}/blacklist.txt"
whitelist_list="${files}/whitelist.txt"

target_user="${user_id}"

if [[ -s "${aliases_list}" ]] && alias="$(grep -x "${user_id} .*" "${aliases_list}")"
then
    user_id="$(cut -F 2 <<< "${alias}")"
fi

if [[ -s "${blacklist_list}" ]] && grep -qx "${user_id}" "${blacklist_list}"
then
    exit
fi

if [[ -s "${whitelist_list}" ]] && ! grep -qx "${user_id}" "${whitelist_list}"
then
    exit
fi

user_config="${users}/${user_id}"
default_user_config="${users}/0"
