# Copyright (C) 2024-2025 Maria Lisina
# Copyright (C) 2024-2025 Danil Lisin
# SPDX-License-Identifier: Apache-2.0

if [[ -n "${nocommand_source}" ]]
then
    exit 0
fi

until mkdir "${user_config}_source.lock"
do
    sleep 1
done

. "${units}/sn_auth.zsh"

rmdir "${user_config}_source.lock"

if [[ -n "${output_text}" ]]
then
    return 0
fi

. "${units}/sn_get.zsh"

if [[ -n "${output_text}" ]]
then
    return 0
fi

source_table=(
    "Danbooru" d danbooru_id
    "Gelbooru" g gelbooru_id
    "Idol Complex" i idol_id
    "Konachan.com" k konachan_id
    "Sankaku Channel" s sankaku_id
    "yande.re" y yandere_id
)

minimum_similarity="$(jq -r ".header.minimum_similarity" "${sn_file}")"
highest_similarity=0
highest_index=0

for ((idx = 0; idx >= 0; idx++))
do
    similarity="$(jq -r ".results.[${idx}].header.similarity" "${sn_file}")"

    if [[ "${similarity}" == "null" ]]
    then
        break
    fi

    if [[ ${highest_similarity} -lt ${similarity} ]]
    then
        highest_similarity=${similarity}
        highest_index=${idx}
    fi
done

if [[ ${highest_similarity} -lt ${minimum_similarity} || ${highest_similarity} -lt 70.00 ]]
then
    output_text="No results found"
    return 0
fi

thumbnail="$(jq -r ".results.[${highest_index}].header.thumbnail" "${sn_file}")"
link_preview_options="$(
    jq --null-input --compact-output \
        --arg url "${thumbnail}" \
        '{"url": $url, "prefer_small_media": true, "show_above_text": true}'
)"

output_text="$(printf "<b>SauceNAO</b>\n<b>Similarity:</b> %.2f%%" "${highest_similarity}")"

reply_markup="{}"
keyboard_offset=0

while [[ ${#source_table} -ge 3 ]]
do
    ib_id="$(jq -r ".results.[${highest_index}].data.${source_table[3]}" "${sn_file}")"

    if [[ "${ib_id}" == "null" ]]
    then
        shift 3 source_table
        continue
    fi

    output_text="$(printf "%s\n<b>%s ID:</b> <code>%s</code>" "${output_text}" "${source_table[1]}" "${ib_id}")"

    if [[ "${source_table[3]}" == "idol_id" ]]
    then
        ib_id="$(jq -r ".results.[${highest_index}].header.index_name" "${sn_file}" | cut -d ' ' -f 6 | cut -d '_' -f 1)"
        output_text="$(printf "%s\n<b>%s MD5:</b> <code>%s</code>" "${output_text}" "${source_table[1]}" "${ib_id}")"
    fi

    keyboard_text1="${source_table[1]}"
    keyboard_query1="post ${source_table[2]} ${ib_id}"

    reply_markup="$(
        jq --compact-output \
            --argjson offset "$(printf "%u" "${keyboard_offset}")" \
            --arg text1 "${keyboard_text1}" \
            --arg query1 "${keyboard_query1}" \
            '.inline_keyboard[$offset] += [{"text": $text1, "switch_inline_query_current_chat": $query1}]' \
        <<< "${reply_markup}"
    )"

    keyboard_offset=$((keyboard_offset + 0.5))
    shift 3 source_table
done
