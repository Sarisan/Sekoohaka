# Copyright (C) 2024-2026 Maria Lisina
# Copyright (C) 2024-2026 Danil Lisin
# SPDX-License-Identifier: Apache-2.0

until mkdir "${user_config}.lock"
do
    sleep 1
done

if [[ -n "${ib_raw}" ]]
then
    ib_dfield5="${ib_login_file}=$(< "${login_file}")"
    ib_dfield6="${ib_key_file}=$(< "${key_file}")"
fi

if [[ -f "${timestamp_file}" ]]
then
    ib_ctime=$(strftime %s)
    ib_mtime=$(< "${timestamp_file}")

    if [[ $((ib_ctime - ib_mtime)) -gt ${ib_expire} ]]
    then
        if [[ -n "${ib_lock}" ]]
        then
            source "${units}/ib_lock.zsh" &

            output_title="Refreshing ${ib_name} session..."
            output_text="Try again in a few seconds"
            notification_text="${output_title} ${output_text}"
        else
            source "${units}/ib_auth.zsh"
        fi
    fi
fi

if [[ -f "${token_file}" ]]
then
    ib_headers="${ib_header} $(< "${token_file}")"
fi

rmdir "${user_config}.lock"
