# Copyright (C) 2024-2025 Maria Lisina
# Copyright (C) 2024-2025 Danil Lisin
# SPDX-License-Identifier: Apache-2.0

until mkdir "${config}/${user_id}_auth.lock" > /dev/null 2>&1
do
    sleep 1
done

if [ -f "${ib_config}/legacy" ]
then
    . "${ib_config}/legacy"
fi

if [ -f "${ib_config}/timestamp" ]
then
    ib_ctime=$(date +%s)
    ib_mtime=$(cat "${ib_config}/timestamp")

    if [ $((ib_ctime - ib_mtime)) -gt ${ib_expire} ]
    then
        if [ -n "${ib_lock}" ]
        then
            . "${units}/ib_lock.sh" &

            output_title="Refreshing access token..."
            output_text="Try again in a few seconds"
            notification_text="${output_title} ${output_text}"
        else
            . "${units}/ib_auth.sh"
        fi
    fi
fi

if [ -f "${ib_config}/token" ]
then
    ib_header="${ib_authorization} $(cat "${ib_config}/token")"
fi

rm -fr "${config}/${user_id}_auth.lock"
