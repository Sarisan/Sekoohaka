# Copyright (C) 2024-2025 Maria Lisina
# Copyright (C) 2024-2025 Danil Lisin
# SPDX-License-Identifier: Apache-2.0

ib_parent=0
. "${units}/ib_name.zsh"
. "${units}/ib_common.zsh"

if [[ -n "${output_text}" ]]
then
    return 0
fi

ib_children_ids=($(jq -r ".${ib_iarray}[].${ib_iid}" "${ib_file}"))
output_text="$(printf "<b>Children IDs:</b>")"

for children_id in ${ib_children_ids[@]}
do
    output_text="$(printf "%s <code>%s</code>" "${output_text}" "${children_id}")"
done
