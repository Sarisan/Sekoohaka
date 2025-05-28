# Copyright (C) 2024-2025 Maria Lisina
# Copyright (C) 2024-2025 Danil Lisin
# SPDX-License-Identifier: Apache-2.0

if [[ -z "${collect_dumps}" ]]
then
    return 0
fi

if [[ -n "${dump}" ]]
then
    mkdir -p "${dumps}/${update_id}"
fi

for dump_file in ${dump[@]}
do
    until mkdir "${cache}/${dump_file%.*}.lock"
    do
        sleep 1
    done

    if [[ -f "${cache}/${dump_file}" ]]
    then
        mv "${cache}/${dump_file}" "${dumps}/${update_id}"
    fi

    rmdir "${cache}/${dump_file%.*}.lock"
done
