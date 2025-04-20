# Copyright (C) 2024-2025 Maria Lisina
# Copyright (C) 2024-2025 Danil Lisin
# SPDX-License-Identifier: Apache-2.0

case "${ib_board}" in
    (a|d)
        ib_auth="https://danbooru.donmai.us/profile.json"
        ib_config="danbooru"
        ib_authorization="Authorization: Baisc"
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
        ib_noauth=0
        ib_config="idol"
        ib_login_file="login"
        ib_key_file="password"
        ib_login_word="login"
        ib_key_word="password"
    ;;
    (s)
        ib_auth="https://sankakuapi.com/auth/token"
        ib_config="sankaku"
        ib_authorization="Authorization: Bearer"
        ib_expire=86400
        ib_login_file="login"
        ib_key_file="password"
        ib_login_word="login"
        ib_key_word="password"
    ;;
    (k|y)
        case "${ib_board}" in
            (k)
                ib_auth="https://konachan.com/user.json"
                ib_config="konachan"
            ;;
            (y)
                ib_auth="https://yande.re/user.json"
                ib_config="yandere"
            ;;
        esac

        ib_login_file="username"
        ib_key_file="api_key"
        ib_login_word="username"
        ib_key_word="API key"
    ;;
esac
