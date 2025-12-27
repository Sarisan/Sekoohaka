# Copyright (C) 2024-2025 Maria Lisina
# Copyright (C) 2024-2025 Danil Lisin
# SPDX-License-Identifier: Apache-2.0

ib_error_url="https://cdn.donmai.us/original/fb/b6/fbb6c45cac3194754dd1feb997cb8ad6.jpg"
ib_error_width=536
ib_error_height=516

case "${ib_board}" in
    (a|d)
        source "${config}/donmai.zsh"
    ;;
    (g)
        source "${config}/gelbooru.zsh"
    ;;
    (i|s)
        source "${config}/sankakucomplex.zsh"
    ;;
    (k|y)
        source "${config}/moebooru.zsh"
    ;;
esac
