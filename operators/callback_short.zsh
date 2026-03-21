# Copyright (C) 2024-2026 Maria Lisina
# Copyright (C) 2024-2026 Danil Lisin
# SPDX-License-Identifier: Apache-2.0

until mkdir "${user_config}.lock"
do
    sleep 1
done

if [[ -n "${1}" ]]
then
    short_query="${@}"
    shift ${#}
else
    notification_text="You must specify query"

    rmdir "${user_config}.lock"
    return
fi

shorts_config="${user_config}/shorts"

if ! mkdir -p "${shorts_config}"
then
    notification_text="Failed to create user config"

    log_text="callback_short (${update_id}): ${notification_text}"
    source "${units}/log.zsh"

    rmdir "${user_config}.lock"
    return
fi

short_hash="$(sha1sum <<< "${short_query}" | cut -F 1)"
short="${shorts_config}/${short_hash}"
shorts=($(ls -1 "${shorts_config}"))

if [[ -f "${short}" ]]
then
    rm -f "${short}"
    notification_text="Removed shortcut"
elif [[ ${#shorts} -le ${shorts_limit} ]]
then
    printf "%s\n" "${short_query}" > "${short}"
    notification_text="Saved shortcut"
else
    notification_text="Too many shortcuts"
fi

shorts=($(ls -1 "${shorts_config}"))

if [[ ${#shorts} -eq 0 ]]
then
    rmdir "${shorts_config}"
fi

rmdir "${user_config}.lock"
