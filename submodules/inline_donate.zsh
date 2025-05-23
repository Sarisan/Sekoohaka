# Copyright (C) 2024-2025 Maria Lisina
# Copyright (C) 2024-2025 Danil Lisin
# SPDX-License-Identifier: Apache-2.0

if ! [[ -s "${files}/donate.txt" ]]
then
    . "${submods}/inline_help.zsh"
    return 0
fi

output_title="Donate"
output_text="$(< "${files}/donate.txt")"
output_description="Click to send the details"

results="$(jq --null-input --compact-output \
    --arg id "${query_id}" \
    --arg title "${output_title}" \
    --arg text "${output_text}" \
    --arg description "${output_description}" \
    '[{"type": "article", "id": $id, "title": $title, "input_message_content": {"message_text": $text, "parse_mode": "HTML"}, "description": $description}]')"
