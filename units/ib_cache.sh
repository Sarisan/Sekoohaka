# Copyright (C) 2024-2025 Maria Lisina
# Copyright (C) 2024-2025 Danil Lisin
# SPDX-License-Identifier: Apache-2.0

until mkdir "${cache}/${ib_hash}.lock"
do
    sleep 1
done

ib_post="$(jq -c ".${ib_iarray}[${array_count}]" "${ib_file}")"
ib_file="${cache}/${ib_hash}.json"

if [ -n "${ib_iarray}" ]
then
    printf '{"%s":[%s]}' "${ib_iarray}" "${ib_post}" | jq -c > "${ib_file}"
else
    printf '[%s]' "${ib_post}" | jq -c > "${ib_file}"
fi

rm -fr "${cache}/${ib_hash}.lock"
