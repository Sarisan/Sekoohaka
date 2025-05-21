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

    if [[ "${reply_text}" != "null" ]]
    then
        ib_reply_name="$(printf "%s" "${reply_text}" | sed '1!d')"
        ib_post_id="$(printf "%s" "${reply_text}" | sed '2!d' | parameter 2)"

        for ib_board in ${board_table[@]}
        do
            . "${units}/ib_config.zsh"

            if [[ "${ib_reply_name}" = "${ib_name}" ]]
            then
                break
            fi
        done

        if [[ -z "${ib_parent}" && "${ib_name}" = "Idol Complex" ]] && echo "${reply_text}" | grep -q 'MD5'
        then
            ib_post_id="$(printf "%s" "${reply_text}" | grep 'MD5' | parameter 2)"
        fi

        set -- ${ib_board} ${ib_post_id}
    fi
fi
