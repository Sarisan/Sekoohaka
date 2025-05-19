# Copyright (C) 2024-2025 Maria Lisina
# Copyright (C) 2024-2025 Danil Lisin
# SPDX-License-Identifier: Apache-2.0

until mkdir "${user_config}_auth.lock"
do
    sleep 1
done

if [[ -f "${user_config}/${ib_config}/legacy" ]]
then
    . "${user_config}/${ib_config}/legacy"
fi

if [[ -f "${user_config}/${ib_config}/timestamp" ]]
then
    ib_ctime=$(date +%s)
    ib_mtime=$(cat "${user_config}/${ib_config}/timestamp")

    if [[ $((ib_ctime - ib_mtime)) -gt ${ib_expire} ]]
    then
        if [[ -n "${ib_lock}" ]]
        then
            . "${units}/ib_lock.zsh" &

            output_title="Refreshing access token..."
            output_text="Try again in a few seconds"
            notification_text="${output_title} ${output_text}"
        else
            . "${units}/ib_auth.zsh"
        fi
    fi
fi

if [[ -f "${user_config}/${ib_config}/token" ]]
then
    ib_header="${ib_authorization} $(cat "${user_config}/${ib_config}/token")"
fi

rm -fr "${user_config}_auth.lock"
