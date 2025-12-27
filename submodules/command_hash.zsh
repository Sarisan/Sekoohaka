# Copyright (C) 2024-2025 Maria Lisina
# Copyright (C) 2024-2025 Danil Lisin
# SPDX-License-Identifier: Apache-2.0

if [[ -n "${1}" ]]
then
    ib_post_md5="${1}"
    shift
else
    output_text="You must specify MD5 hash"
    return 0
fi

if ! [[ ${#ib_post_md5} -eq 32 ]]
then
    output_text="Invalid MD5 hash"
    return 0
fi

ib_post="${cache}/${update_id}_id.txt"
ib_sample="${cache}/${update_id}_sample.txt"

for lock in "${ib_post}" "${ib_sample}"
do
    until mkdir "${lock%.*}.lock"
    do
        sleep 1
    done
done

for ib_board in {a..z}
do
    source "${units}/ib_config.zsh"
    source "${units}/ib_hash.zsh" &
    wait

    if ! [[ -f "${ib_post}" ]]
    then
        continue
    fi

    ib_id="$(< "${ib_post}")"

    keyboard_text1="${ib_name}"
    keyboard_query1="post ${ib_board} ${ib_id}"

    reply_markup="$(
        jq --compact-output \
            --argjson offset "$(printf "%u" "${keyboard_offset}")" \
            --arg text1 "${keyboard_text1}" \
            --arg query1 "${keyboard_query1}" \
            '.inline_keyboard[$offset] += [{"text": $text1, "switch_inline_query_current_chat": $query1}]' \
        <<< "${reply_markup:-"{}"}"
    )"

    keyboard_offset=$((keyboard_offset + 0.5))
done

if [[ -f "${ib_sample}" ]]
then
    output_text="$(printf "<b>MD5:</b> <code>%s</code>" "${ib_post_md5}")"

    link_preview_options="$(
        jq --null-input --compact-output \
            --arg url "$(< "${ib_sample}")" \
            '{"url": $url, "prefer_small_media": true, "show_above_text": true}'
    )"
else
    output_text="No results found"
fi

for lock in "${ib_post}" "${ib_sample}"
do
    rmdir "${lock%.*}.lock"
done
