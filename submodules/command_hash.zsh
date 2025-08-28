# Copyright (C) 2024-2025 Maria Lisina
# Copyright (C) 2024-2025 Danil Lisin
# SPDX-License-Identifier: Apache-2.0

if [[ -n "${1}" ]]
then
    ib_post_md5="${1}"
    shift
else
    output_text="You must specify MD5 hash"
    return 0
fi

if ! [[ ${#ib_post_md5} -eq 32 ]]
then
    output_text="Invalid MD5 hash"
    return 0
fi

ib_post_id="${cache}/${update_id}_${ib_post_md5}.txt"

for ib_board in {a..z}
do
    unset ib_name
    . "${units}/ib_config.zsh"

    if [[ -z "${ib_name}" ]]
    then
        continue
    fi

    rm -f "${ib_post_id}"

    . "${units}/ib_hash.zsh" &
    wait

    if ! [[ -f "${ib_post_id}" ]]
    then
        continue
    fi

    ib_id="$(< "${ib_post_id}")"
    ids_text="$(printf "%s\n<b>%s ID:</b> <code>%s</code>" "${ids_text}" "${ib_name}" "${ib_id}")"

    keyboard_text1="${ib_name}"
    keyboard_query1="post ${ib_board} ${ib_id}"

    reply_markup="$(
        jq --compact-output \
            --argjson offset "$(printf "%u" "${keyboard_offset}")" \
            --arg text1 "${keyboard_text1}" \
            --arg query1 "${keyboard_query1}" \
            '.inline_keyboard[$offset] += [{"text": $text1, "switch_inline_query_current_chat": $query1}]' \
        <<< "${reply_markup:-"{}"}"
    )"

    keyboard_offset=$((keyboard_offset + 0.5))
done

if [[ -n "${ids_text}" ]]
then
    output_text="${ids_text}"
else
    output_text="No results found"
fi
