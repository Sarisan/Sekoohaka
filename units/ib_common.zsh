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
        output_text="Unsupported image board"
        notification_text="${output_text}"

        return 0
    fi

    shift
else
    output_title="Invalid arguments"
    output_text="You must specify the image board"
    notification_text="${output_text}"

    return 0
fi

if [[ -n "${1}" ]]
then
    ib_post_id="${1}"
    shift
elif [[ -n "${ib_parent}" ]]
then
    output_text="You must specify the parent post ID"
else
    output_title="Invalid arguments"
    output_text="You must specify the post ID or the MD5 hash"
    notification_text="${output_text}"

    return 0
fi

if [[ -n "${ib_parent}" ]]
then
    ib_query="parent:${ib_post_id}"
elif [[ ${#ib_post_id} -eq 32 ]]
then
    ib_query="md5:${ib_post_id}"
elif [[ "${ib_name}" = "Idol Complex" ]]
then
    ib_query="id_range:${ib_post_id}"
else
    ib_query="id:${ib_post_id}"
fi

ib_hash="$(printf "%s%s%s" "${user_id}" "${ib_board}" "${ib_post_id}" | enhash)"
. "${units}/ib_file.zsh"
