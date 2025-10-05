# Copyright (C) 2024-2025 Maria Lisina
# Copyright (C) 2024-2025 Danil Lisin
# SPDX-License-Identifier: Apache-2.0

auth_dir="${user_config}/${ib_config}"

timestamp_file="${auth_dir}/timestamp"
token_file="${auth_dir}/token"

case "${ib_board}" in
    (a|d)
        . "${auth}/config/donmai.zsh"
    ;;
    (g)
        . "${auth}/config/gelbooru.zsh"
    ;;
    (i|s)
        . "${auth}/config/sankakucomplex.zsh"
    ;;
    (k|y)
        . "${auth}/config/moebooru.zsh"
    ;;
esac

login_file="${auth_dir}/${ib_login_file}"
key_file="${auth_dir}/${ib_key_file}"
