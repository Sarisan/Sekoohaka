# Copyright (C) 2024-2025 Maria Lisina
# Copyright (C) 2024-2025 Danil Lisin
# SPDX-License-Identifier: Apache-2.0

. "${units}/ib_name.zsh"
. "${units}/ib_common.zsh"

if [[ -n "${output_text}" ]]
then
    return 0
fi

. "${units}/ib_post.zsh"

link_preview_options="$(jq --null-input --compact-output \
    --arg url "${ib_sample_url}" \
    '{"url": $url, "prefer_small_media": true, "show_above_text": true}')"

keyboard_text1="Post link"
keyboard_url1="${ib_url}$(printf "%s" "${ib_post_id}" | urlencode)"

reply_markup="$(jq --null-input --compact-output \
    --arg text1 "${keyboard_text1}" \
    --arg url1 "${keyboard_url1}" \
    '{"inline_keyboard": [[{"text": $text1, "url": $url1}]]}')"

if [[ ${#ib_tags} -gt 0 ]]
then
    keyboard_text1="Tags (${#ib_tags})"
    keyboard_data1="tags ${ib_board} ${ib_post_id}"

    reply_markup="$(printf "%s" "${reply_markup}" | jq --compact-output \
        --arg text1 "${keyboard_text1}" \
        --arg data1 "${keyboard_data1}" \
        '.inline_keyboard.[0] += [{"text": $text1, "callback_data": $data1}]')"
fi
