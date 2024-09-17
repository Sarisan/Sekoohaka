# Copyright (C) 2024 Maria Lisina
# Copyright (C) 2024 Danil Lisin
# SPDX-License-Identifier: Apache-2.0

until mkdir "${config}/${user_id}_auth.lock" > /dev/null 2>&1
do
    sleep 1
done

. "${units}/ib_auth.sh"

rm -fr "${config}/${user_id}_auth.lock"
