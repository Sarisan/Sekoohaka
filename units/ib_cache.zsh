# Copyright (C) 2024-2025 Maria Lisina
# Copyright (C) 2024-2025 Danil Lisin
# SPDX-License-Identifier: Apache-2.0

ib_post="$(jq -c ".${ib_iarray}[$((idx - 1))]" "${ib_file}")"
ib_query="id:${ib_id}"

ib_hash="$(sha1sum <<< "${user_id}${ib_board}${ib_query}" | cut -d ' ' -f 1)"
ib_file="${cache}/${ib_hash}.json"

until mkdir "${cache}/${ib_hash}.lock"
do
    sleep 1
done

if [[ -n "${ib_iarray}" ]]
then
    printf '{"%s":[%s]}' "${ib_iarray}" "${ib_post}" | jq -c > "${ib_file}"
else
    printf '[%s]' "${ib_post}" | jq -c > "${ib_file}"
fi

rmdir "${cache}/${ib_hash}.lock"
