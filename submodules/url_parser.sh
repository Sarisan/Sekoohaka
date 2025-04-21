# Copyright (C) 2024-2025 Maria Lisina
# Copyright (C) 2024-2025 Danil Lisin
# SPDX-License-Identifier: Apache-2.0

url_table="
    https://safebooru.donmai.us/posts/.* a / 5
    safebooru.donmai.us/posts/.* a / 3
    https://danbooru.donmai.us/posts/.* d / 5
    danbooru.donmai.us/posts/.* d / 3
    https://gelbooru.com/index.php?page=post&s=view&id=.* g = 4
    gelbooru.com/index.php?page=post&s=view&id=.* g = 4
    https://idol.sankakucomplex.com/.*/posts/.* i / 6
    idol.sankakucomplex.com/.*/posts/.* i / 4
    https://idol.sankakucomplex.com/posts/.* i / 5
    idol.sankakucomplex.com/posts/.* i / 3
    https://konachan.com/post/show/.* k / 6
    konachan.com/post/show/.* k / 4
    https://chan.sankakucomplex.com/.*/posts/.* s / 6
    chan.sankakucomplex.com/.*/posts/.* s / 4
    https://chan.sankakucomplex.com/posts/.* s / 5
    chan.sankakucomplex.com/posts/.* s / 3
    https://yande.re/post/show/.* y / 6
    yande.re/post/show/.* y / 4
"

ib_mode="p"
set -- ${url_table}

while [ ${#} -ge 4 ]
do
    if echo ${command} | grep -qx "${1}"
    then
        ib_board="${2}"
        ib_post_id="$(printf "%s" ${command} | cut -d ${3} -f ${4} | cut -d '?' -f 1)"

        break
    fi

    shift 4
done

if [ -z "${ib_post_id}" ]
then
    exit 0
fi

. "${units}/ib_config.sh"
. "${units}/ib_authconfig.sh"

if [ ${#ib_post_id} -gt 32 ]
then
    exit 0
elif [ ${#ib_post_id} -eq 32 ]
then
    ib_query="md5:${ib_post_id}"
elif [ "${ib_name}" = "Idol Complex" ]
then
    ib_query="id_range:${ib_post_id}"
else
    ib_query="id:${ib_post_id}"
fi

ib_hash="$(printf "%s%s%s" "${user_id}" "${ib_board}" "${ib_post_id}" | enhash)"
. "${units}/ib_file.sh"

if [ -n "${output_text}" ]
then
    keyboard_text1="Delete"
    keyboard_data1="delete"

    reply_markup="$(jq --null-input --compact-output \
        --arg text1 "${keyboard_text1}" \
        --arg data1 "${keyboard_data1}" \
        '{"inline_keyboard": [[{"text": $text1, "callback_data": $data1}]]}')"

    return 0
fi

. "${units}/ib_post.sh"

link_preview_options="$(jq --null-input --compact-output \
    --arg url "${ib_sample_url}" \
    '{"url": $url, "prefer_small_media": true, "show_above_text": true}')"

keyboard_text1="Post link"
keyboard_url1="${ib_url}$(printf "%s" "${ib_post_id}" | urlencode)"
keyboard_text2="Delete"
keyboard_data2="delete"

reply_markup="$(jq --null-input --compact-output \
    --arg text1 "${keyboard_text1}" \
    --arg url1 "${keyboard_url1}" \
    --arg text2 "${keyboard_text2}" \
    --arg data2 "${keyboard_data2}" \
    '{"inline_keyboard": [[{"text": $text1, "url": $url1}], [{"text": $text2, "callback_data": $data2}]]}')"

if [ ${ib_tags_count} -gt 0 ]
then
    keyboard_text1="Tags (${ib_tags_count})"
    keyboard_data1="tags ${ib_board} ${ib_post_id}"

    reply_markup="$(printf "%s" "${reply_markup}" | jq --compact-output \
        --arg text1 "${keyboard_text1}" \
        --arg data1 "${keyboard_data1}" \
        '.inline_keyboard.[0] += [{"text": $text1, "callback_data": $data1}]')"
fi
