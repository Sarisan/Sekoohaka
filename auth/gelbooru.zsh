# Copyright (C) 2024-2026 Maria Lisina
# Copyright (C) 2024-2026 Danil Lisin
# SPDX-License-Identifier: Apache-2.0

output_text="Authorization cannot be verified, make sure you provided correct credentials"

printf "%s\n" "${ib_login}" > "${login_file}"
printf "%s\n" "${ib_key}" > "${key_file}"
