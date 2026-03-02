# Copyright (C) 2024-2026 Maria Lisina
# Copyright (C) 2024-2026 Danil Lisin
# SPDX-License-Identifier: Apache-2.0

case "${ib_board}" in
    (i)
        ib_auth="https://i.sankakuapi.com"
        ib_config="idolcomplex"
    ;;
    (s)
        ib_auth="https://sankakuapi.com"
        ib_config="sankakuchannel"
    ;;
esac

ib_header="Authorization: Bearer"
ib_expire=86400
ib_login_file="login"
ib_key_file="password"
ib_login_word="login"
ib_key_word="password"
