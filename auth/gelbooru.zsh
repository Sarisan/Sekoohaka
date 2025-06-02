# Copyright (C) 2024-2025 Maria Lisina
# Copyright (C) 2024-2025 Danil Lisin
# SPDX-License-Identifier: Apache-2.0

printf '%s="%s"\n%s="%s"\n' \
    "ib_dfield5" "user_id=${ib_login}" \
    "ib_dfield6" "api_key=${ib_key}" > "${legacy_file}"
