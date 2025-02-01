# Copyright (C) 2024-2025 Maria Lisina
# Copyright (C) 2024-2025 Danil Lisin
# SPDX-License-Identifier: Apache-2.0

case "${ib_board}" in
    (d)
        ib_config="${config}/${user_id}/danbooru"
        ib_authorization="Authorization: Baisc"
        ib_login_file="login"
        ib_key_file="api_key"
        ib_login_word="login"
        ib_key_word="API key"
    ;;
    (g)
        ib_config="${config}/${user_id}/gelbooru"
        ib_noverify=0
        ib_login_file="user_id"
        ib_key_file="api_key"
        ib_login_word="user ID"
        ib_key_word="API key"
    ;;
    (i)
        ib_config="${config}/${user_id}/idol"
        ib_noverify=0
        ib_login_file="login"
        ib_key_file="password"
        ib_login_word="login"
        ib_key_word="password"
    ;;
    (s)
        ib_config="${config}/${user_id}/sankaku"
        ib_authorization="Authorization: Bearer"
        ib_expire=36000
        ib_login_file="login"
        ib_key_file="password"
        ib_login_word="login"
        ib_key_word="password"
    ;;
    (k|y)
        case "${ib_board}" in
            (k)
                ib_auth="https://konachan.com"
                ib_config="${config}/${user_id}/konachan"
            ;;
            (y)
                ib_auth="https://yande.re"
                ib_config="${config}/${user_id}/yandere"
            ;;
        esac

        ib_login_file="username"
        ib_key_file="api_key"
        ib_login_word="username"
        ib_key_word="API key"
    ;;
esac
