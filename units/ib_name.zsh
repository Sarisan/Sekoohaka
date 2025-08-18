# Copyright (C) 2024-2025 Maria Lisina
# Copyright (C) 2024-2025 Danil Lisin
# SPDX-License-Identifier: Apache-2.0

if [[ -n "${1}" ]]
then
    return 0
fi

reply_text="$(jq -r '.message.reply_to_message.text' "${update}")"

if [[ "${reply_text}" == "null" ]]
then
    reply_text="$(jq -r '.message.reply_to_message.caption' "${update}")"
fi

if [[ "${reply_text}" == "null" ]]
then
    output_text="You must specify the Image Board and the post ID or the MD5 hash, or use this command in reply to a message"
    return 0
fi

ib_reply_name="$(sed '1!d' <<< "${reply_text}")"

for ib_board in ${board_table[@]}
do
    . "${units}/ib_config.zsh"

    if [[ "${ib_reply_name}" == "${ib_name}" ]]
    then
        break
    elif [[ "${ib_board}" == "${board_table[-1]}" ]]
    then
        output_text="Could not find Image Board in replied message"
        return 0
    fi
done

ib_post_id="$(sed '2!d' <<< "${reply_text}" | cut -d ' ' -f 2)"

if [[ -z "${ib_post_id}" ]]
then
    output_text="Could not find post ID in replied message"
    return 0
fi

set -- ${ib_board} ${ib_post_id}
