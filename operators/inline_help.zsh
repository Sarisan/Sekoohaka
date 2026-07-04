# Copyright (C) 2024-2026 Maria Lisina
# Copyright (C) 2024-2026 Danil Lisin
# SPDX-License-Identifier: Apache-2.0

output_title="Sekoohaka Bot"
output_text="${help_general}"
output_description="Click to send help message"

results="$(
    jq --null-input --compact-output \
        --arg id "${query_id}" \
        --arg title "${output_title}" \
        --arg text "${output_text}" \
        --arg description "${output_description}" \
        '[{"type": "article", "id": $id, "title": $title, "input_message_content": {"message_text": $text, "parse_mode": "HTML", "link_preview_options": {"is_disabled": true}}, "description": $description}]'
)"

source "${units}/help.zsh"

if [[ -n "${reply_markup}" ]]
then
    results="$(
        jq --compact-output \
            --argjson reply_markup "${reply_markup}" \
            '.[0] += {"reply_markup": $reply_markup}' \
        <<< "${results}"
    )"
fi
