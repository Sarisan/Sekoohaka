# Copyright (C) 2024-2026 Maria Lisina
# Copyright (C) 2024-2026 Danil Lisin
# SPDX-License-Identifier: Apache-2.0

until mkdir "${user_config}_auth.lock"
do
    sleep 1
done

source "${units}/ib_auth.zsh"

rmdir "${user_config}_auth.lock"
