# Copyright (C) 2024-2026 Maria Lisina
# Copyright (C) 2024-2026 Danil Lisin
# SPDX-License-Identifier: Apache-2.0

ib_error_url="https://cdn.donmai.us/original/fb/b6/fbb6c45cac3194754dd1feb997cb8ad6.jpg"
ib_error_width=536
ib_error_height=516

case "${ib_board}" in
    (a|d)
        source "${config}/donmai.zsh"
    ;;
    (i|s)
        source "${config}/sankakucomplex.zsh"
    ;;
    (k|y)
        source "${config}/moebooru.zsh"
    ;;
esac

auth_dir="${user_config}/${ib_config}"

if ! [[ -d "${auth_dir}" || -z "${ib_mode}" ]]
then
    user_id=0
    user_config="${users}/${user_id}"
    auth_dir="${user_config}/${ib_config}"
fi

timestamp_file="${auth_dir}/timestamp"
token_file="${auth_dir}/token"
login_file="${auth_dir}/${ib_login_file}"
key_file="${auth_dir}/${ib_key_file}"
