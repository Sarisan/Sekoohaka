# Copyright (C) 2024-2025 Maria Lisina
# Copyright (C) 2024-2025 Danil Lisin
# SPDX-License-Identifier: Apache-2.0

minimum_similarity="$(jq -r ".header.minimum_similarity" "${sn_file}" | sed 's/\.//')"
highest_similarity=0
highest_index=0
array_count=0

while [ -n "${array_count}" ]
do
    similarity="$(jq -r ".results.[${array_count}].header.similarity" "${sn_file}" | sed 's/\.//')"

    if [ "${similarity}" = "null" ]
    then
        break
    fi

    if [ ${highest_similarity} -lt ${similarity} ]
    then
        highest_similarity=${similarity}
        highest_index=${array_count}
    fi

    array_count=$((array_count + 1))
done

if [ ${highest_similarity} -lt ${minimum_similarity} ]
then
    output_text="No results found"
    return 0
fi

thumbnail="$(jq -r ".results.[${highest_index}].header.thumbnail" "${sn_file}")"
similarity="$(printf "%.2f" "$(printf "%s" "${highest_similarity} / 100" | bc -l)")"

link_preview_options="$(jq --null-input --compact-output \
    --arg url "${thumbnail}" \
    '{"url": $url, "prefer_small_media": true, "show_above_text": true}')"

danbooru_id="$(jq -r ".results.[${highest_index}].data.danbooru_id" "${sn_file}")"
gelbooru_id="$(jq -r ".results.[${highest_index}].data.gelbooru_id" "${sn_file}")"
idol_id="$(jq -r ".results.[${highest_index}].data.idol_id" "${sn_file}")"
konachan_id="$(jq -r ".results.[${highest_index}].data.konachan_id" "${sn_file}")"
sankaku_id="$(jq -r ".results.[${highest_index}].data.sankaku_id" "${sn_file}")"
yandere_id="$(jq -r ".results.[${highest_index}].data.yandere_id" "${sn_file}")"

output_text="<b>SauceNAO</b>"
output_text="$(printf "%s\n<b>Similarity:</b> %s%%" "${output_text}" "${similarity}")"

if [ "${danbooru_id}" != "null" ]
then
    output_text="$(printf "%s\n<b>Danbooru ID:</b> <code>%s</code>" "${output_text}" "${danbooru_id}")"
fi

if [ "${gelbooru_id}" != "null" ]
then
    output_text="$(printf "%s\n<b>Gelbooru ID:</b> <code>%s</code>" "${output_text}" "${gelbooru_id}")"
fi

if [ "${idol_id}" != "null" ]
then
    idol_md5="$(jq -r ".results.[${highest_index}].header.index_name" "${sn_file}" | parameter 6 | cut -d '_' -f 1)"

    output_text="$(printf "%s\n<b>Idol Complex ID:</b> <code>%s</code>" "${output_text}" "${idol_id}")"
    output_text="$(printf "%s\n<b>Idol Complex MD5:</b> <code>%s</code>" "${output_text}" "${idol_md5}")"
fi

if [ "${konachan_id}" != "null" ]
then
    output_text="$(printf "%s\n<b>Konachan.com ID:</b> <code>%s</code>" "${output_text}" "${konachan_id}")"
fi

if [ "${sankaku_id}" != "null" ]
then
    output_text="$(printf "%s\n<b>Sankaku Channel ID:</b> <code>%s</code>" "${output_text}" "${sankaku_id}")"
fi

if [ "${yandere_id}" != "null" ]
then
    output_text="$(printf "%s\n<b>yande.re ID:</b> <code>%s</code>" "${output_text}" "${yandere_id}")"
fi
