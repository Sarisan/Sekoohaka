# Copyright (C) 2024-2026 Maria Lisina
# Copyright (C) 2024-2026 Danil Lisin
# SPDX-License-Identifier: Apache-2.0

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
