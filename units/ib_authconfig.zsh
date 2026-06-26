# Copyright (C) 2024-2026 Maria Lisina
# Copyright (C) 2024-2026 Danil Lisin
# SPDX-License-Identifier: Apache-2.0

case "${ib_board}" in
    (a|d)
        source "${auth}/config/donmai.zsh"
    ;;
    (i|s)
        source "${auth}/config/sankakucomplex.zsh"
    ;;
    (k|y)
        source "${auth}/config/moebooru.zsh"
    ;;
esac

auth_dir="${user_config}/${ib_config}"

if ! [[ -d "${auth_dir}" || -z "${ib_mode}" ]]
then
    user_config="${default_user_config}"
    auth_dir="${user_config}/${ib_config}"
fi

timestamp_file="${auth_dir}/timestamp"
token_file="${auth_dir}/token"
login_file="${auth_dir}/${ib_login_file}"
key_file="${auth_dir}/${ib_key_file}"
