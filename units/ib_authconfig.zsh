# Copyright (C) 2024-2025 Maria Lisina
# Copyright (C) 2024-2025 Danil Lisin
# SPDX-License-Identifier: Apache-2.0

case "${ib_board}" in
    (a|d)
        case "${ib_board}" in
            (a)
                ib_auth="https://safebooru.donmai.us"
                ib_config="safebooru"
            ;;
            (d)
                ib_auth="https://danbooru.donmai.us"
                ib_config="danbooru"
            ;;
        esac

        ib_header="Authorization: Baisc"
        ib_login_file="login"
        ib_key_file="api_key"
        ib_login_word="login"
        ib_key_word="API key"
    ;;
    (g)
        ib_noauth=0
        ib_config="gelbooru"
        ib_login_file="user_id"
        ib_key_file="api_key"
        ib_login_word="user ID"
        ib_key_word="API key"
    ;;
    (i)
        ib_auth="https://idol.sankakucomplex.com"
        ib_config="idol"
        ib_expire=86400
        ib_login_file="username"
        ib_key_file="password"
        ib_login_word="email or username"
        ib_key_word="password"
    ;;
    (s)
        ib_auth="https://sankakuapi.com"
        ib_config="sankaku"
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
                ib_config="konachan"
            ;;
            (y)
                ib_auth="https://yande.re"
                ib_config="yandere"
            ;;
        esac

        ib_login_file="username"
        ib_key_file="api_key"
        ib_login_word="username"
        ib_key_word="API key"
    ;;
esac
