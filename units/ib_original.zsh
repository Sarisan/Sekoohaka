# Copyright (C) 2024-2025 Maria Lisina
# Copyright (C) 2024-2025 Danil Lisin
# SPDX-License-Identifier: Apache-2.0

ib_file_size="$(jq -r ".${ib_iarray}[0].${ib_isize}" "${ib_file}")"
ib_file_url="$(jq -r ".${ib_iarray}[0].${ib_ifile}" "${ib_file}")"

. "${units}/ib_size.zsh"

if [[ -n "${ib_file_url}" && "${ib_file_url}" != "null" ]]
then
    . "${units}/ib_meta.zsh"
else
    output_text="No original file found"
    return 0
fi

if [[ -n "${ib_file_size}" && "${ib_file_size}" != "null" && ${ib_file_size} -gt 0 ]]
then
    if [[ ${ib_file_size} -gt 20971520 ]]
    then
        output_text="File size is too large"
    fi
else
    output_text="Failed to get file size"
fi
