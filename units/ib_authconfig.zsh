# Copyright (C) 2024-2025 Maria Lisina
# Copyright (C) 2024-2025 Danil Lisin
# SPDX-License-Identifier: Apache-2.0

legacy_file="${user_config}/${ib_config}/legacy"
timestamp_file="${user_config}/${ib_config}/timestamp"
cookies_file="${user_config}/${ib_config}/cookies"
token_file="${user_config}/${ib_config}/token"

case "${ib_board}" in
    (a|d)
        case "${ib_board}" in
            (a)
                ib_auth="https://safebooru.donmai.us"
            ;;
            (d)
                ib_auth="https://danbooru.donmai.us"
            ;;
        esac

        ib_header="Authorization: Baisc"
        ib_login_file="login"
        ib_key_file="api_key"
        ib_login_word="login"
        ib_key_word="API key"
    ;;
    (g)
        ib_auth=0
        ib_login_file="user_id"
        ib_key_file="api_key"
        ib_login_word="user ID"
        ib_key_word="API key"
    ;;
    (i)
        ib_auth="https://idol.sankakucomplex.com"
        ib_cookie="_idolcomplex_session"
        ib_expire=86400
        ib_login_file="username"
        ib_key_file="password"
        ib_login_word="email or username"
        ib_key_word="password"
    ;;
    (s)
        ib_auth="https://sankakuapi.com"
        ib_header="Authorization: Bearer"
        ib_expire=86400
        ib_login_file="login"
        ib_key_file="password"
        ib_login_word="login"
        ib_key_word="password"
    ;;
    (k|y)
        case "${ib_board}" in
            (k)
                ib_auth="https://konachan.com"
            ;;
            (y)
                ib_auth="https://yande.re"
            ;;
        esac

        ib_login_file="username"
        ib_key_file="api_key"
        ib_login_word="username"
        ib_key_word="API key"
    ;;
esac
