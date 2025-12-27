# Copyright (C) 2024-2026 Maria Lisina
# Copyright (C) 2024-2026 Danil Lisin
# SPDX-License-Identifier: Apache-2.0

if [[ -n "${no_clear}" ]]
then
    return 0
fi

for file in $(find "${cache}" -follow -type f)
do
    if ! mkdir "${file%.*}.lock"
    then
        continue
    fi

    file_ctime=$(strftime %s)
    file_mtime=$(stat +mtime "${file}")

    if [[ $((file_ctime - file_mtime)) -gt $((cache_time + 20)) ]]
    then
        rm -f "${file}"
    fi

    rmdir "${file%.*}.lock"
done
