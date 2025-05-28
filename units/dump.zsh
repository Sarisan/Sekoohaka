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

for cache_dump in ${dump[@]}
do
    until mkdir "${cache}/${cache_dump%.*}.lock"
    do
        sleep 1
    done

    if [[ -f "${cache}/${cache_dump}" ]]
    then
        cp "${cache}/${cache_dump}" "${dumps}/${update_id}"
    fi

    rmdir "${cache}/${cache_dump%.*}.lock"
done
