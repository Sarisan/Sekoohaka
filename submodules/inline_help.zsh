# Copyright (C) 2024-2025 Maria Lisina
# Copyright (C) 2024-2025 Danil Lisin
# SPDX-License-Identifier: Apache-2.0

. "${units}/help.zsh"

output_title="Sekoohaka Bot"
output_description="Click to send the help message"

results="$(jq --null-input --compact-output \
    --arg id "${query_id}" \
    --arg title "${output_title}" \
    --arg text "${output_text}" \
    --arg description "${output_description}" \
    '[{"type": "article", "id": $id, "title": $title, "input_message_content": {"message_text": $text, "parse_mode": "HTML", "link_preview_options": {"is_disabled": true}}, "description": $description}]')"
