# Copyright (C) 2024-2025 Maria Lisina
# Copyright (C) 2024-2025 Danil Lisin
# SPDX-License-Identifier: Apache-2.0

target_user="${user_id}"

if [[ ${aliases_length} -gt 0 ]] && alias="$(grep -x "${user_id} .*" <<< "${aliases_list}")"
then
    user_id="$(printf "%s" "${alias}" | parameter 2)"
fi

if [[ ${blacklist_length} -gt 0 ]] && grep -qx "${user_id}" <<< "${blacklist_list}"
then
    exit 0
fi

if [[ ${whitelist_length} -gt 0 ]] && !grep -qx "${user_id}" <<< "${whitelist_list}"
then
    exit 0
fi

user_config="${users}/${user_id}"
