# Copyright (C) 2024-2026 Maria Lisina
# Copyright (C) 2024-2026 Danil Lisin
# SPDX-License-Identifier: Apache-2.0

url_table=(
    a 3 "safebooru.donmai.us/posts/"
    d 3 "danbooru.donmai.us/posts/"
    i 4 "www.idolcomplex.com/.*/posts/"
    i 4 "idolcomplex.com/.*/posts/"
    i 3 "www.idolcomplex.com/posts/"
    i 3 "idolcomplex.com/posts/"
    k 4 "konachan.com/post/show/"
    s 4 "www.sankakucomplex.com/.*/posts/"
    i 4 "sankakucomplex.com/.*/posts/"
    s 3 "www.sankakucomplex.com/posts/"
    i 3 "sankakucomplex.com/posts/"
    y 4 "yande.re/post/show/"
)

ib_mode="p"

while [[ ${#url_table} -ge 3 ]]
do
    if url_line="$(grep -o "https://\?${url_table[3]}.*" <<< "${command} ${@}")"
    then
        url_line="$(sed -e 's/https:\/\///' -e 's/ .*//' <<< "${url_line}")"

        ib_board="${url_table[1]}"
        ib_post_id="$(cut -d '/' -f ${url_table[2]} <<< "${url_line}" | cut -d '?' -f 1)"

        break
    fi

    shift 3 url_table
done

if [[ -z "${ib_post_id}" ]]
then
    exit
fi

source "${units}/ib_config.zsh"
source "${units}/ib_authconfig.zsh"

if [[ ${#ib_post_id} -gt 32 ]]
then
    exit
elif [[ ${#ib_post_id} -eq 32 ]]
then
    ib_query="md5:${ib_post_id}"
else
    ib_query="id:${ib_post_id}"
fi

ib_hash="$(sha1sum <<< "${user_id}${ib_board}${ib_query}" | cut -F 1)"
ib_file="${cache}/${ib_hash}.json"

until mkdir "${cache}/${ib_hash}.lock"
do
    sleep 1
done

source "${units}/ib_file.zsh"

if [[ -n "${output_text}" ]]
then
    keyboard_text1="Delete"
    keyboard_data1="delete"

    reply_markup="$(
        jq --null-input --compact-output \
            --arg text1 "${keyboard_text1}" \
            --arg data1 "${keyboard_data1}" \
            '{"inline_keyboard": [[{"text": $text1, "callback_data": $data1}]]}'
    )"

    rmdir "${cache}/${ib_hash}.lock"
    return
fi

source "${units}/ib_post.zsh"

link_preview_options="$(
    jq --null-input --compact-output \
        --arg url "${ib_sample_url}" \
        '{"url": $url, "prefer_small_media": true, "show_above_text": true}'
)"

keyboard_text1="Post link"
keyboard_url1="${ib_url}$(urlencode <<< "${ib_id}")"
keyboard_text2="Delete"
keyboard_data2="delete"

reply_markup="$(
    jq --null-input --compact-output \
        --arg text1 "${keyboard_text1}" \
        --arg url1 "${keyboard_url1}" \
        --arg text2 "${keyboard_text2}" \
        --arg data2 "${keyboard_data2}" \
        '{"inline_keyboard": [[{"text": $text1, "url": $url1}], [{"text": $text2, "callback_data": $data2}]]}'
)"

if [[ ${#ib_tags} -gt 0 ]]
then
    keyboard_text1="Tags (${#ib_tags})"
    keyboard_data1="tags ${ib_board} ${ib_post_id}"

    reply_markup="$(
        jq --compact-output \
            --arg text1 "${keyboard_text1}" \
            --arg data1 "${keyboard_data1}" \
            '.inline_keyboard[0] += [{"text": $text1, "callback_data": $data1}]' \
        <<< "${reply_markup}"
    )"
fi

rmdir "${cache}/${ib_hash}.lock"
