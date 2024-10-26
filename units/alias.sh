# Copyright (C) 2024 Maria Lisina
# Copyright (C) 2024 Danil Lisin
# SPDX-License-Identifier: Apache-2.0

aliases="${config}/alias"

if [ -f "${aliases}" ] && alias_id="$(grep -w "${user_id}" "${aliases}" | parameter 2)"
then
    user_id="${alias_id}"
fi
