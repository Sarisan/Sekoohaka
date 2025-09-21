# Copyright (C) 2024-2025 Maria Lisina
# Copyright (C) 2024-2025 Danil Lisin
# SPDX-License-Identifier: Apache-2.0

url_table=(
    a / 5 "https://safebooru.donmai.us/posts/.*"
    a / 3 "safebooru.donmai.us/posts/.*"
    d / 5 "https://danbooru.donmai.us/posts/.*"
    d / 3 "danbooru.donmai.us/posts/.*"
    g = 4 "https://gelbooru.com/index.php?page=post&s=view&id=.*"
    g = 4 "gelbooru.com/index.php?page=post&s=view&id=.*"
    i / 6 "https://www.idolcomplex.com/.*/posts/.*"
    i / 4 "www.idolcomplex.com/.*/posts/.*"
    i / 4 "idolcomplex.com/.*/posts/.*"
    i / 5 "https://www.idolcomplex.com/posts/.*"
    i / 3 "www.idolcomplex.com/posts/.*"
    i / 3 "idolcomplex.com/posts/.*"
    k / 6 "https://konachan.com/post/show/.*"
    k / 4 "konachan.com/post/show/.*"
    s / 6 "https://www.sankakucomplex.com/.*/posts/.*"
    s / 4 "www.sankakucomplex.com/.*/posts/.*"
    i / 4 "sankakucomplex.com/.*/posts/.*"
    s / 5 "https://www.sankakucomplex.com/posts/.*"
    s / 3 "www.sankakucomplex.com/posts/.*"
    i / 3 "sankakucomplex.com/posts/.*"
    y / 6 "https://yande.re/post/show/.*"
    y / 4 "yande.re/post/show/.*"
)

ib_mode="p"

while [[ ${#url_table} -ge 4 ]]
do
    if grep -qx "${url_table[4]}" <<< ${command}
    then
        ib_board="${url_table[1]}"
        ib_post_id="$(cut -d ${url_table[2]} -f ${url_table[3]} <<< ${command} | cut -d '?' -f 1)"

        break
    fi

    shift 4 url_table
done

if [[ -z "${ib_post_id}" ]]
then
    exit 0
fi

. "${units}/ib_config.zsh"
. "${units}/ib_authconfig.zsh"

if [[ ${#ib_post_id} -gt 32 ]]
then
    exit 0
elif [[ ${#ib_post_id} -eq 32 ]]
then
    ib_query="md5:${ib_post_id}"
else
    ib_query="id:${ib_post_id}"
fi

ib_hash="$(sha1sum <<< "${user_id}${ib_board}${ib_query}" | cut -d ' ' -f 1)"
ib_file="${cache}/${ib_hash}.json"

until mkdir "${cache}/${ib_hash}.lock"
do
    sleep 1
done

. "${units}/ib_file.zsh"

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
    return 0
fi

. "${units}/ib_post.zsh"

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
