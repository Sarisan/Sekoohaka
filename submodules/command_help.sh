# Copyright (C) 2024-2025 Maria Lisina
# Copyright (C) 2024-2025 Danil Lisin
# SPDX-License-Identifier: Apache-2.0

output_text="$(cat "${files}/help.txt" | sed "s/{version}/${version}/")"

link_preview_options="$(jq --null-input --compact-output \
    '{"is_disabled": true}')"
