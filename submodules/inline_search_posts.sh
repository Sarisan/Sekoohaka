# Copyright (C) 2024-2025 Maria Lisina
# Copyright (C) 2024-2025 Danil Lisin
# SPDX-License-Identifier: Apache-2.0

ib_created_at="$(jq -r ".${ib_iarray}[${array_count}].${ib_icreated}" "${ib_file}")"
ib_file_size="$(jq -r ".${ib_iarray}[${array_count}].${ib_isize}" "${ib_file}")"
ib_file_url="$(jq -r ".${ib_iarray}[${array_count}].${ib_ifile}" "${ib_file}")"

unset ib_date_text ib_resolution_text ib_type_text ib_size_text
. "${units}/ib_date.sh"
. "${units}/ib_meta.sh"

if [ -n "${ib_preview}" ]
then
    case "${ib_type}" in
        (gif | video)
            ib_sample_url="${ib_preview_url}"
            ib_type="photo"
        ;;
    esac
fi

output_text="$(printf "<b>%s</b>\n<b>ID:</b> <code>%s</code>" "${ib_name}" "${ib_id}")"

if [ -n "${ib_date_text}" ]
then
    output_text="$(printf "%s\n<b>Date:</b> <code>%s</code>" "${output_text}" "${ib_date_text}")"
fi

if [ -n "${ib_metadata}" ]
then
    if [ -n "${ib_resolution_text}" ]
    then
        output_text="$(printf "%s\n<b>Resolution:</b> %s" "${output_text}" "${ib_resolution_text}")"
    fi

    if [ -n "${ib_size_text}" ]
    then
        output_text="$(printf "%s\n<b>Size:</b> %s" "${output_text}" "${ib_size_text}")"
    fi

    if [ -n "${ib_type_text}" ]
    then
        output_text="$(printf "%s\n<b>Type:</b> %s" "${output_text}" "${ib_type_text}")"
    fi
fi

keyboard_text1="Post link"
keyboard_url1="${ib_url}$(printf "%s" "${ib_id}" | urlencode)"
keyboard_text2="Resume"
keyboard_query2="${command} ${ib_board} ${inline_page}"

if [ -n "${inline_query}" ]
then
    keyboard_query2="${keyboard_query2} ${inline_query}"
fi

case "${ib_type}" in
    (photo)
        result="$(jq --null-input --compact-output \
            --arg id "${ib_id}" \
            --arg photo_url "${ib_sample_url}" \
            --arg thumbnail_url "${ib_preview_url}" \
            --arg photo_width "${ib_width}" \
            --arg photo_height "${ib_height}" \
            --arg caption "${output_text}" \
            --arg text1 "${keyboard_text1}" \
            --arg url1 "${keyboard_url1}" \
            --arg text2 "${keyboard_text2}" \
            --arg query2 "${keyboard_query2}" \
            '{"type": "photo", "id": $id, "photo_url": $photo_url, "thumbnail_url": $thumbnail_url, "photo_width": $photo_width, "photo_height": $photo_height, "caption": $caption, "parse_mode": "HTML", "reply_markup": {"inline_keyboard": [[{"text": $text1, "url": $url1}, {"text": $text2, "switch_inline_query_current_chat": $query2}]]}}')"
    ;;
    (gif)
        result="$(jq --null-input --compact-output \
            --arg id "${ib_id}" \
            --arg gif_url "${ib_file_url}" \
            --arg thumbnail_url "${ib_preview_url}" \
            --arg gif_width "${ib_width}" \
            --arg gif_height "${ib_height}" \
            --arg caption "${output_text}" \
            --arg text1 "${keyboard_text1}" \
            --arg url1 "${keyboard_url1}" \
            --arg text2 "${keyboard_text2}" \
            --arg query2 "${keyboard_query2}" \
            '{"type": "gif", "id": $id, "gif_url": $gif_url, "thumbnail_url": $thumbnail_url, "gif_width": $gif_width, "gif_height": $gif_height, "caption": $caption, "parse_mode": "HTML", "reply_markup": {"inline_keyboard": [[{"text": $text1, "url": $url1}, {"text": $text2, "switch_inline_query_current_chat": $query2}]]}}')"
    ;;
    (video)
        result="$(jq --null-input --compact-output \
            --arg id "${ib_id}" \
            --arg mpeg4_url "${ib_file_url}" \
            --arg thumbnail_url "${ib_preview_url}" \
            --arg mpeg4_width "${ib_width}" \
            --arg mpeg4_height "${ib_height}" \
            --arg caption "${output_text}" \
            --arg text1 "${keyboard_text1}" \
            --arg url1 "${keyboard_url1}" \
            --arg text2 "${keyboard_text2}" \
            --arg query2 "${keyboard_query2}" \
            '{"type": "mpeg4_gif", "id": $id, "mpeg4_url": $mpeg4_url, "thumbnail_url": $thumbnail_url, "mpeg4_width": $mpeg4_width, "mpeg4_height": $mpeg4_height, "caption": $caption, "parse_mode": "HTML", "reply_markup": {"inline_keyboard": [[{"text": $text1, "url": $url1}, {"text": $text2, "switch_inline_query_current_chat": $query2}]]}}')"
    ;;
esac

if [ -n "${ib_quick}" ]
then
    keyboard_text1="Original"
    keyboard_query1="original ${ib_board} ${ib_id}"
    keyboard_text2="Post"
    keyboard_query2="post ${ib_board} ${ib_id}"

    result="$(printf "%s" "${result}" | jq --compact-output \
        --arg text1 "${keyboard_text1}" \
        --arg query1 "${keyboard_query1}" \
        --arg text2 "${keyboard_text2}" \
        --arg query2 "${keyboard_query2}" \
        '.reply_markup.inline_keyboard += [[{"text": $text1, "switch_inline_query_current_chat": $query1}, {"text": $text2, "switch_inline_query_current_chat": $query2}]]')"
fi

if [ "${caching_mode}" = "advanced" ]
then
    ib_hash="$(printf "%s%s%s" "${user_id}" "${ib_board}" "${ib_id}" | enhash)"
    . "${units}/ib_cache.sh" &
fi
