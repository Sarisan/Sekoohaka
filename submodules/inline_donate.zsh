# Copyright (C) 2024-2026 Maria Lisina
# Copyright (C) 2024-2026 Danil Lisin
# SPDX-License-Identifier: Apache-2.0

if [[ -n "${nocommand_donate}" ]]
then
    source "${submods}/inline_help.zsh"
    return
fi

output_title="Donate"
output_text="${donate_content}"
output_description="Click to send details"

results="$(
    jq --null-input --compact-output \
        --arg id "${query_id}" \
        --arg title "${output_title}" \
        --arg text "${output_text}" \
        --arg description "${output_description}" \
        '[{"type": "article", "id": $id, "title": $title, "input_message_content": {"message_text": $text, "parse_mode": "HTML"}, "description": $description}]'
)"
