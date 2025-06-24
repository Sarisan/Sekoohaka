# Copyright (C) 2024-2025 Maria Lisina
# Copyright (C) 2024-2025 Danil Lisin
# SPDX-License-Identifier: Apache-2.0

if [[ -z "${clear_cache}" ]]
then
    return 0
fi

for file in $(ls -1 "${cache}")
do
    until mkdir "${cache}/${file%.*}.lock"
    do
        sleep 1
    done

    file_ctime=$(strftime %s)
    file_mtime=$(stat +mtime "${cache}/${file}")

    if [[ $((file_ctime - file_mtime)) -gt $((cache_time + 20)) ]]
    then
        rm -f "${cache}/${file}"
    fi

    rmdir "${cache}/${file%.*}.lock"
done
