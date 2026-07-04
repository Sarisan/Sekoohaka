# Copyright (C) 2024-2026 Maria Lisina
# Copyright (C) 2024-2026 Danil Lisin
# SPDX-License-Identifier: Apache-2.0

output_text="${help_general}"
source "${units}/help.zsh"

link_preview_options="$(
    jq --null-input --compact-output \
        '{"is_disabled": true}'
)"
