# Copyright (C) 2024 Maria Lisina
# Copyright (C) 2024 Danil Lisin
# SPDX-License-Identifier: Apache-2.0

if [ -n "${cache_removal}" ]
then
    exit 0
fi

if ! mkdir "${cache}.lock" > /dev/null 2>&1
then
    exit 0
fi

set -- $(ls -x "${cache}")

while [ ${#} -ge 1 ]
do
    until mkdir "${cache}/${1%.*}.lock" > /dev/null 2>&1
    do
        sleep 1
    done

    cache_ctime=$(date +%s)
    cache_mtime=$(stat -c %Y "${cache}/${1}")

    if [ $((cache_ctime - cache_mtime)) -gt $((caching_time + 10)) ]
    then
        rm -f "${cache}/${1}"
    fi

    rm -fr "${cache}/${1%.*}.lock"
    shift
done

rm -fr "${cache}.lock"
