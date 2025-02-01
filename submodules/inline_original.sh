# Copyright (C) 2024-2025 Maria Lisina
# Copyright (C) 2024-2025 Danil Lisin
# SPDX-License-Identifier: Apache-2.0

ib_lock=0
. "${units}/ib_common.sh"

if [ -n "${output_text}" ]
then
    results="$(jq --null-input --compact-output \
        --arg id "${query_id}" \
        --arg title "${output_title}" \
        --arg text "${output_text}" \
        --arg description "${output_text}" \
        '[{"type": "article", "id": $id, "title": $title, "input_message_content": {"message_text": $text}, "description": $description}]')"

    return 0
fi

. "${units}/ib_original.sh"

if [ -n "${output_text}" ]
then
    output_title="An error occurred"

    results="$(jq --null-input --compact-output \
        --arg id "${query_id}" \
        --arg title "${output_title}" \
        --arg text "${output_text}" \
        --arg description "${output_text}" \
        '[{"type": "article", "id": $id, "title": $title, "input_message_content": {"message_text": $text}, "description": $description}]')"
else
    output_title="Original file of post ${ib_post_id}"
    output_description="Click to send the original file"

    results="$(jq --null-input --compact-output \
        --arg id "${query_id}" \
        --arg title "${output_title}" \
        --arg document_url "${ib_file_url}" \
        --arg description "${output_description}" \
        --arg thumbnail_url "${ib_preview_url}" \
        '[{"type": "document", "id": $id, "title": $title, "document_url": $document_url, "mime_type": "application/zip", "description": $description, "thumbnail_url", $thumbnail_url}]')"
fi

if [ -n "${ib_file_url}" ] && [ "${ib_file_url}" != "null" ]
then
    keyboard_text1="Original file link"
    keyboard_url1="${ib_file_url}"

    results="$(printf "%s" "${results}" | jq --compact-output \
        --arg text1 "${keyboard_text1}" \
        --arg url1 "${keyboard_url1}" \
        '.[0] += {"reply_markup": {"inline_keyboard": [[{"text": $text1, "url": $url1}]]}}')"
fi
