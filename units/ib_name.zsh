# Copyright (C) 2024-2025 Maria Lisina
# Copyright (C) 2024-2025 Danil Lisin
# SPDX-License-Identifier: Apache-2.0

board_table=(a d g i k s y)

if [[ -z "${1}" ]]
then
    reply_text="$(jq -r '.message.reply_to_message.text' "${update}")"

    if [[ "${reply_text}" = "null" ]]
    then
        reply_text="$(jq -r '.message.reply_to_message.caption' "${update}")"
    fi

    if [[ "${reply_text}" = "null" ]]
    then
        return 0
    fi

    ib_reply_name="$(printf "%s" "${reply_text}" | sed '1!d')"

    for ib_board in ${board_table[@]}
    do
        . "${units}/ib_config.zsh"

        if [[ "${ib_board}" = "${board_table[-1]}" && "${ib_reply_name}" != "${ib_name}" ]]
        then
            output_text="Could not find image board in replied message"
            return 0
        fi

        if [[ "${ib_reply_name}" = "${ib_name}" ]]
        then
            break
        fi
    done

    if [[ -z "${ib_parent}" && "${ib_name}" = "Idol Complex" ]] && echo "${reply_text}" | grep -q 'MD5'
    then
        ib_post_id="$(printf "%s" "${reply_text}" | grep 'MD5' | parameter 2)"
    else
        ib_post_id="$(printf "%s" "${reply_text}" | sed '2!d' | parameter 2)"
    fi

    if [[ -z "${ib_post_id}" ]]
    then
        output_text="Could not find post ID in replied message"
        return 0
    fi

    set -- ${ib_board} ${ib_post_id}
fi
