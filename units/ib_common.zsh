# Copyright (C) 2024-2025 Maria Lisina
# Copyright (C) 2024-2025 Danil Lisin
# SPDX-License-Identifier: Apache-2.0

if [[ -n "${1}" ]]
then
    ib_board="${1}"
    ib_mode="p"

    . "${units}/ib_config.zsh"
    . "${units}/ib_authconfig.zsh"

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
elif [[ -n "${ib_parent}" ]]
then
    output_text="You must specify parent post ID"
else
    output_title="Invalid arguments"
    output_text="You must specify post ID or MD5 hash"
    notification_text="${output_text}"

    return 0
fi

if [[ -n "${ib_parent}" ]]
then
    ib_query="parent:${ib_post_id}"
elif [[ ${#ib_post_id} -eq 32 ]]
then
    ib_query="md5:${ib_post_id}"
else
    ib_query="id:${ib_post_id}"
fi

ib_hash="$(sha1sum <<< "${user_id}${ib_board}${ib_query}" | cut -d ' ' -f 1)"
. "${units}/ib_file.zsh"
