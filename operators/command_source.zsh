# Copyright (C) 2024-2026 Maria Lisina
# Copyright (C) 2024-2026 Danil Lisin
# SPDX-License-Identifier: Apache-2.0

if [[ -n "${nocommand_source}" ]]
then
    exit
fi

until mkdir "${user_config}.lock"
do
    sleep 1
done

source "${units}/sn_auth.zsh"

if [[ -d "${user_config}" ]]
then
    user_data=($(ls -1 "${user_config}"))

    if [[ ${#user_data} -eq 0 ]]
    then
        rmdir "${user_config}"
    fi
fi

rmdir "${user_config}.lock"

if [[ -n "${output_text}" ]]
then
    return
fi

source "${units}/sn_get.zsh"

if [[ -n "${output_text}" ]]
then
    return
fi

booru_table=(
    danbooru_id d "Danbooru"
    idol_id i "Idol Complex"
    konachan_id k "Konachan.com"
    sankaku_id s "Sankaku Channel"
    yandere_id y "yande.re"
)

external_table=(
    pixiv_id "www.pixiv.net/artworks" "Pixiv"
    tweet_id "x.com/i/status" "X (Twitter)"
)

minimum_similarity="$(jq -r ".header.minimum_similarity" <<< "${sn_data}")"

for ((idx = 0; idx >= 0; idx++))
do
    similarity="$(jq -r ".results.[${idx}].header.similarity" <<< "${sn_data}")"

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
    return
fi

index_name="$(jq -r ".results.[${highest_index}].header.index_name" <<< "${sn_data}")"

thumbnail="$(jq -r ".results.[${highest_index}].header.thumbnail" <<< "${sn_data}")"
link_preview_options="$(
    jq --null-input --compact-output \
        --arg url "${thumbnail}" \
        '{"url": $url, "prefer_small_media": true, "show_above_text": true}'
)"

output_text="$(printf "<b>SauceNAO</b>\n<b>Similarity:</b> %.2f%%" "${highest_similarity}")"

while [[ ${#booru_table} -ge 3 ]]
do
    if ! jq -e ".results.[${highest_index}].data|has(\"${booru_table[1]}\")" <<< "${sn_data}" > /dev/null
    then
        shift 3 booru_table
        continue
    fi

    index_md5="$(cut -d '_' -f 1 <<< "${index_name##* }")"

    keyboard_text1="${booru_table[3]}"
    keyboard_query1="post ${booru_table[2]} ${index_md5}"

    reply_markup="$(
        jq --compact-output \
            --argjson offset "$(printf "%u" "${keyboard_offset}")" \
            --arg text1 "${keyboard_text1}" \
            --arg query1 "${keyboard_query1}" \
            '.inline_keyboard[$offset] += [{"text": $text1, "switch_inline_query_current_chat": $query1}]' \
        <<< "${reply_markup:-"{}"}"
    )"

    keyboard_offset=$((keyboard_offset + 0.5))
    shift 3 booru_table
done

while [[ ${#external_table} -ge 3 ]]
do
    source_id="$(jq -r ".results.[${highest_index}].data.${external_table[1]}" <<< "${sn_data}")"

    if [[ "${source_id}" == "null" ]]
    then
        shift 3 external_table
        continue
    fi

    keyboard_text1="${external_table[3]}"
    keyboard_url1="${external_table[2]}/${source_id}"

    reply_markup="$(
        jq --compact-output \
            --argjson offset "$(printf "%u" "${keyboard_offset}")" \
            --arg text1 "${keyboard_text1}" \
            --arg url1 "${keyboard_url1}" \
            '.inline_keyboard[$offset] += [{"text": $text1, "url": $url1}]' \
        <<< "${reply_markup:-"{}"}"
    )"

    keyboard_offset=$((keyboard_offset + 0.5))
    shift 3 external_table
done
