# Copyright (C) 2024 Maria Lisina
# Copyright (C) 2024 Danil Lisin
# SPDX-License-Identifier: Apache-2.0

. "${units}/help.sh"

link_preview_options="$(jq --null-input --compact-output \
    '{"is_disabled": true}')"
