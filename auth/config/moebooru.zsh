# Copyright (C) 2024-2026 Maria Lisina
# Copyright (C) 2024-2026 Danil Lisin
# SPDX-License-Identifier: Apache-2.0

case "${ib_board}" in
    (k)
        ib_auth="https://konachan.com"
    ;;
    (y)
        ib_auth="https://yande.re"
    ;;
esac

ib_raw=0
ib_login_file="username"
ib_key_file="api_key"
ib_login_word="username"
ib_key_word="API key"
