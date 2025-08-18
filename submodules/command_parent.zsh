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

keyboard_text1="Open inline"
keyboard_query1="posts ${ib_board} parent:${ib_post_id}"

reply_markup="$(
    jq --null-input --compact-output \
        --arg text1 "${keyboard_text1}" \
        --arg query1 "${keyboard_query1}" \
        '.inline_keyboard[0] += [{"text": $text1, "switch_inline_query_current_chat": $query1}]'
)"

output_text="$(printf "<b>Children IDs:</b>")"
ib_children_ids=($(jq -r ".${ib_iarray}[].${ib_iid}" "${ib_file}"))

for children_id in ${ib_children_ids[@]}
do
    output_text="$(printf "%s <code>%s</code>" "${output_text}" "${children_id}")"
done
