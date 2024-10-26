# Copyright (C) 2024 Maria Lisina
# Copyright (C) 2024 Danil Lisin
# SPDX-License-Identifier: Apache-2.0

aliases="${config}/aliases"
blacklist="${config}/blacklist"
whitelist="${config}/whitelist"

if [ -f "${aliases}" ] && alias_id="$(grep -w "${user_id}" "${aliases}" | parameter 2)"
then
    user_id="${alias_id}"
fi

if [ -f "${blacklist}" ] && grep -qw "${user_id}" "${blacklist}"
then
    exit 0
fi

if [ -f "${whitelist}" ] && ! grep -qw "${user_id}" "${whitelist}"
then
    exit 0
fi
