# Copyright (C) 2024-2026 Maria Lisina
# Copyright (C) 2024-2026 Danil Lisin
# SPDX-License-Identifier: Apache-2.0

for dir in $(find "${cache}" "${users}" -follow -name "*.lock")
do
    dir_ctime=$(strftime %s)
    dir_mtime=$(stat +mtime "${dir}")

    if [[ $((dir_ctime - dir_mtime)) -gt 30 ]]
    then
        rmdir "${dir}"
    fi
done
