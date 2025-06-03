# Copyright (C) 2024-2025 Maria Lisina
# Copyright (C) 2024-2025 Danil Lisin
# SPDX-License-Identifier: Apache-2.0

legacy_file="${user_config}/${ib_config}/legacy"
timestamp_file="${user_config}/${ib_config}/timestamp"
cookies_file="${user_config}/${ib_config}/cookies"
token_file="${user_config}/${ib_config}/token"

case "${ib_board}" in
    (a|d)
        . "${config}/auth/donmai.zsh"
    ;;
    (g)
        . "${config}/auth/gelbooru.zsh"
    ;;
    (i)
        . "${config}/auth/idolcomplex.zsh"
    ;;
    (s)
        . "${config}/auth/sankakuchannel.zsh"
    ;;
    (k|y)
        . "${config}/auth/moebooru.zsh"
    ;;
esac
