# Copyright (C) 2024-2025 Maria Lisina
# Copyright (C) 2024-2025 Danil Lisin
# SPDX-License-Identifier: Apache-2.0

if [ -z "${clear_cache}" ]
then
    exit 0
fi

if ! mkdir "${cache}.lock" > /dev/null 2>&1
then
    exit 0
fi

for file in $(ls -x "${cache}")
do
    until mkdir "${cache}/${file%.*}.lock" > /dev/null 2>&1
    do
        sleep 1
    done

    cache_ctime=$(date +%s)
    cache_mtime=$(stat -c %Y "${cache}/${file}")

    if [ $((cache_ctime - cache_mtime)) -gt $((caching_time + 10)) ]
    then
        rm -f "${cache}/${file}"
    fi

    rm -fr "${cache}/${file%.*}.lock"
done

rm -fr "${cache}.lock"
