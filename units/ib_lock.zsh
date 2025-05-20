# Copyright (C) 2024-2025 Maria Lisina
# Copyright (C) 2024-2025 Danil Lisin
# SPDX-License-Identifier: Apache-2.0

until mkdir "${user_config}_auth.lock"
do
    sleep 1
done

. "${units}/ib_auth.zsh"

rmdir "${user_config}_auth.lock"
