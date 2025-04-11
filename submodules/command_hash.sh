# Copyright (C) 2024-2025 Maria Lisina
# Copyright (C) 2024-2025 Danil Lisin
# SPDX-License-Identifier: Apache-2.0

board_table="d g i k s y"

if [ -n "${1}" ]
then
    ib_post_md5="${@}"
    shift ${#}
else
    output_text="You must specify the MD5 hash"
    return 0
fi

if ! [ ${#ib_post_md5} -eq 32 ]
then
    output_text="Invalid MD5 hash provided"
    return 0
fi

ib_posts="${cache}/${update_id}_${ib_post_md5}.txt"

until mkdir "${ib_posts%.*}.lock"
do
    sleep 1
done

for ib_board in ${board_table}
do
    . "${units}/ib_hash.sh" &
done

wait

if [ -s "${ib_posts}" ]
then
    output_text="$(cat "${ib_posts}")"
else
    output_text="No results found"
fi

rm -fr "${ib_posts%.*}.lock"
