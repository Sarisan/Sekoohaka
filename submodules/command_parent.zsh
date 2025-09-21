# Copyright (C) 2024-2025 Maria Lisina
# Copyright (C) 2024-2025 Danil Lisin
# SPDX-License-Identifier: Apache-2.0

ib_parent=0
. "${units}/ib_name.zsh"

if [[ -n "${output_text}" ]]
then
    return 0
fi

. "${units}/ib_common.zsh"

if [[ -n "${output_text}" ]]
then
    return 0
fi

ib_hash="$(sha1sum <<< "${user_id}${ib_board}${ib_query}" | cut -d ' ' -f 1)"
ib_file="${cache}/${ib_hash}.json"

until mkdir "${cache}/${ib_hash}.lock"
do
    sleep 1
done

. "${units}/ib_file.zsh"

if [[ -n "${output_text}" ]]
then
    rmdir "${cache}/${ib_hash}.lock"
    return 0
fi

ib_children_ids=($(jq -r ".${ib_iarray}[].${ib_iid}" "${ib_file}"))
output_text="<b>Children posts:</b> ${#ib_children_ids}"

keyboard_text1="Search posts"
keyboard_query1="posts ${ib_board} parent:${ib_post_id}"

reply_markup="$(
    jq --null-input --compact-output \
        --arg text1 "${keyboard_text1}" \
        --arg query1 "${keyboard_query1}" \
        '.inline_keyboard[0] += [{"text": $text1, "switch_inline_query_current_chat": $query1}]'
)"

rmdir "${cache}/${ib_hash}.lock"
