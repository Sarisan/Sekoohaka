# Copyright (C) 2024-2025 Maria Lisina
# Copyright (C) 2024-2025 Danil Lisin
# SPDX-License-Identifier: Apache-2.0

case "${ib_board}" in
    (i)
        ib_auth="https://i.sankakuapi.com"
    ;;
    (s)
        ib_auth="https://sankakuapi.com"
    ;;
esac

ib_header="Authorization: Bearer"
ib_expire=86400
ib_login_file="login"
ib_key_file="password"
ib_login_word="login"
ib_key_word="password"
