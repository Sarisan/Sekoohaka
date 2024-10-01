# Copyright (C) 2024 Maria Lisina
# Copyright (C) 2024 Danil Lisin
# SPDX-License-Identifier: Apache-2.0

ib_file_size="$(jq -r ".${ib_iarray}[0].${ib_isize}" "${ib_file}")"
ib_file_url="$(jq -r ".${ib_iarray}[0].${ib_ifile}" "${ib_file}")"
ib_preview_url="$(jq -r ".${ib_iarray}[0].${ib_ipreview}" "${ib_file}")"

. "${units}/ib_size.sh"

if [ -n "${ib_file_url}" ] && [ "${ib_file_url}" != "null" ]
then
    if [ "${ib_name}" = "Idol Complex" ]
    then
        ib_file_url="https:${ib_file_url}"
    fi

    if [ -z "${ib_preview_url}" ] || [ "${ib_preview_url}" = "null" ]
    then
        ib_preview_url=${ib_error_url}
    elif [ "${ib_name}" = "Idol Complex" ]
    then
        ib_preview_url="https:${ib_preview_url}"
    fi
else
    output_text="No original file found"
    return 0
fi

if [ -n "${ib_file_size}" ] && [ "${ib_file_size}" != "null" ] && [ ${ib_file_size} -gt 0 ]
then
    if [ ${ib_file_size} -gt ${size_limit} ]
    then
        output_text="File size is too large"
    fi
else
    output_text="Failed to get file size"
fi
