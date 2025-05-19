# Copyright (C) 2024-2025 Maria Lisina
# Copyright (C) 2024-2025 Danil Lisin
# SPDX-License-Identifier: Apache-2.0

until mkdir "${user_config}_short.lock"
do
    sleep 1
done

if [[ -n "${1}" ]]
then
    short_query="${@}"
    shift ${#}
else
    notification_text="You must specify the query"

    rm -fr "${user_config}_short.lock"
    return 0
fi

short_config="${user_config}/short"

if ! mkdir -p "${short_config}"
then
    notification_text="Failed to create user config"

    rm -fr "${user_config}_short.lock"
    return 0
fi

short_hash="$(printf "%s" "${short_query}" | enhash)"
short="${short_config}/${short_hash}"
shorts=($(ls -x "${short_config}"))

if [[ -f "${short}" ]]
then
    rm -f "${short}"
    notification_text="Removed shortcut"
elif [[ ${#shorts} -le ${shorts_limit} ]]
then
    printf "%s" "${short_query}" > "${short}"
    notification_text="Saved shortcut"
else
    notification_text="Too many shortcuts"
fi

rm -fr "${user_config}_short.lock"
