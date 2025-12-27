# Copyright (C) 2024-2026 Maria Lisina
# Copyright (C) 2024-2026 Danil Lisin
# SPDX-License-Identifier: Apache-2.0

if [[ -n "${1}" ]]
then
    ib_board="${1}"
    ib_mode="p"

    source "${units}/ib_config.zsh"
    source "${units}/ib_authconfig.zsh"

    if [[ -z "${ib_data_url}" ]]
    then
        output_title="Invalid arguments"
        output_text="Unsupported Image Board"
        notification_text="${output_text}"

        return 0
    fi

    shift
else
    output_title="Invalid arguments"
    output_text="You must specify Image Board and post ID or MD5 hash"
    notification_text="${output_text}"

    return 0
fi

if [[ -n "${1}" ]]
then
    ib_post_id="${1}"
    shift
else
    output_title="Invalid arguments"
    output_text="You must specify post ID or MD5 hash"
    notification_text="${output_text}"

    return 0
fi

if [[ ${#ib_post_id} -eq 32 ]]
then
    ib_query="md5:${ib_post_id}"
else
    ib_query="id:${ib_post_id}"
fi
