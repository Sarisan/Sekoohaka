# Copyright (C) 2024-2025 Maria Lisina
# Copyright (C) 2024-2025 Danil Lisin
# SPDX-License-Identifier: Apache-2.0

if [[ -n "${nocommand_donate}" ]]
then
    exit 0
fi

output_text="$(< "${files}/donate.txt")"
