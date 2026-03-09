# Copyright (C) 2024-2026 Maria Lisina
# Copyright (C) 2024-2026 Danil Lisin
# SPDX-License-Identifier: Apache-2.0

ib_post="$(jq -c ".[$((idx - 1))]" "${ib_file}")"
ib_query="id:${ib_id}"

ib_hash="$(sha1sum <<< "${user_id}${ib_board}${ib_query}" | cut -d ' ' -f 1)"
ib_file="${cache}/${ib_hash}.json"

until mkdir "${cache}/${ib_hash}.lock"
do
    sleep 1
done

printf '[%s]' "${ib_post}" | jq -c > "${ib_file}"

rmdir "${cache}/${ib_hash}.lock"
