# Copyright (C) 2024-2025 Maria Lisina
# Copyright (C) 2024-2025 Danil Lisin
# SPDX-License-Identifier: Apache-2.0

if [[ -z "${clear_cache}" ]]
then
    exit 0
fi

if ! mkdir "${cache}.lock"
then
    exit 0
fi

for file in $(ls -x "${cache}")
do
    until mkdir "${cache}/${file%.*}.lock"
    do
        sleep 1
    done

    cache_ctime=$(strftime %s)
    cache_mtime=$(stat +mtime "${cache}/${file}")

    if [[ $((cache_ctime - cache_mtime)) -gt $((cache_time + 15)) ]]
    then
        rm -f "${cache}/${file}"
    fi

    rmdir "${cache}/${file%.*}.lock"
done

rmdir "${cache}.lock"
