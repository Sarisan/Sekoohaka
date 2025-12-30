# Copyright (C) 2024-2026 Maria Lisina
# Copyright (C) 2024-2026 Danil Lisin
# SPDX-License-Identifier: Apache-2.0

if [[ -n "${1}" ]]
then
    return
fi

reply_text="$(jq -r '.message.reply_to_message.text' <<< "${update}")"

if [[ "${reply_text}" == "null" ]]
then
    reply_text="$(jq -r '.message.reply_to_message.caption' <<< "${update}")"
fi

if [[ "${reply_text}" == "null" ]]
then
    output_text="You must specify Image Board and post ID or MD5 hash, or use this command in reply to a message"
    return
fi

ib_reply_name="$(sed '1!d' <<< "${reply_text}")"

for ib_board in {a..z} 0
do
    source "${units}/ib_config.zsh"

    if [[ "${ib_reply_name}" == "${ib_name}" ]]
    then
        break
    fi
done

if [[ "${ib_board}" == "0" ]]
then
    output_text="Could not find Image Board in replied message"
    return
fi

ib_post_id="$(sed '2!d' <<< "${reply_text}" | cut -d ' ' -f 2)"

if [[ -z "${ib_post_id}" ]]
then
    output_text="Could not find post ID in replied message"
    return
fi

set -- ${ib_board} ${ib_post_id}
