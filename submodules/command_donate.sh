# Copyright (C) 2024-2025 Maria Lisina
# Copyright (C) 2024-2025 Danil Lisin
# SPDX-License-Identifier: Apache-2.0

if ! [ -s "${files}/donate.txt" ]
then
    exit 0
fi

output_text="$(cat "${files}/donate.txt")"
