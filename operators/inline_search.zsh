# Copyright (C) 2024-2026 Maria Lisina
# Copyright (C) 2024-2026 Danil Lisin
# SPDX-License-Identifier: Apache-2.0

case "${command}" in
    ("pools" | l)
        ib_mode="l"
        inline_options="aq"
    ;;
    ("posts" | p)
        ib_mode="p"
        inline_options="ampq"
    ;;
    ("tags" | t)
        ib_mode="t"
        inline_options="aq"
    ;;
    (*)
        set -- ${inline_query[@]}
        source "${operators}/inline_none.zsh"

        case "${command}" in
            ("shorts")
                source "${operators}/inline_shorts.zsh"
            ;;
            ("help")
                source "${operators}/inline_help.zsh"
            ;;
        esac

        return
    ;;
esac

ib_lock=0
source "${units}/ib_search.zsh"

if [[ -n "${output_text}" ]]
then
    keyboard_text1="Resume"
    keyboard_query1="${command} ${ib_board} ${inline_page}"

    if [[ -n "${search_query}" ]]
    then
        keyboard_query1="${keyboard_query1} ${search_query}"
    fi

    results="$(
        jq --null-input --compact-output \
            --arg id "${query_id}" \
            --arg title "${output_title}" \
            --arg text "${output_text}" \
            --arg text1 "${keyboard_text1}" \
            --arg query1 "${keyboard_query1}" \
            --arg description "${output_text}" \
            '[{"type": "article", "id": $id, "title": $title, "input_message_content": {"message_text": $text}, "reply_markup": {"inline_keyboard": [[{"text": $text1, "switch_inline_query_current_chat": $query1}]]}, "description": $description}]'
    )"

    return
fi

ib_hash="$(sha1sum <<< "${user_id}${ib_mode}${ib_board}${ib_page}${ib_query}" | cut -d ' ' -f 1)"
ib_file="${cache}/${ib_hash}.json"

until mkdir "${cache}/${ib_hash}.lock"
do
    sleep 1
done

source "${units}/ib_file.zsh"

if [[ -n "${output_text}" ]]
then
    keyboard_text1="Resume"
    keyboard_query1="${command} ${ib_board} ${inline_page}"

    if [[ -n "${search_query}" ]]
    then
        keyboard_query1="${keyboard_query1} ${search_query}"
    fi

    results="$(
        jq --null-input --compact-output \
            --arg id "${query_id}" \
            --arg title "${output_title}" \
            --arg text "${output_text}" \
            --arg text1 "${keyboard_text1}" \
            --arg query1 "${keyboard_query1}" \
            --arg description "${output_text}" \
            '[{"type": "article", "id": $id, "title": $title, "input_message_content": {"message_text": $text}, "reply_markup": {"inline_keyboard": [[{"text": $text1, "switch_inline_query_current_chat": $query1}]]}, "description": $description}]'
    )"

    rmdir "${cache}/${ib_hash}.lock"
    return
fi

ib_ids=("${(@f)$(jq -r ".${ib_iarray}[].${ib_iid}" "${ib_file}")}")

case "${ib_mode}" in
    (l)
        ib_created_ats=("${(@f)$(jq -r ".${ib_iarray}[].${ib_icreated}" "${ib_file}")}")
        ib_pools=("${(@f)$(jq -r ".${ib_iarray}[].${ib_ipool}" "${ib_file}")}")
        ib_counts=("${(@f)$(jq -r ".${ib_iarray}[].${ib_icount}" "${ib_file}")}")
    ;;
    (p)
        ib_created_ats=("${(@f)$(jq -r ".${ib_iarray}[].${ib_icreated}" "${ib_file}")}")
        ib_file_sizes=("${(@f)$(jq -r ".${ib_iarray}[].${ib_isize}" "${ib_file}")}")
        ib_file_urls=("${(@f)$(jq -r ".${ib_iarray}[].${ib_ifile}" "${ib_file}")}")
        ib_sample_urls=("${(@f)$(jq -r ".${ib_iarray}[].${ib_isample}" "${ib_file}")}")
        ib_preview_urls=("${(@f)$(jq -r ".${ib_iarray}[].${ib_ipreview}" "${ib_file}")}")
        ib_widths=("${(@f)$(jq -r ".${ib_iarray}[].${ib_iwidth}" "${ib_file}")}")
        ib_heights=("${(@f)$(jq -r ".${ib_iarray}[].${ib_iheight}" "${ib_file}")}")
    ;;
    (t)
        ib_tags=("${(@f)$(jq -r ".${ib_iarray}[].${ib_itag}" "${ib_file}")}")
        ib_counts=("${(@f)$(jq -r ".${ib_iarray}[].${ib_icount}" "${ib_file}")}")
    ;;
esac

for ((idx = 1; idx > 0; idx++))
do
    ib_id="${ib_ids[idx]}"

    if [[ -z "${ib_id}" || "${ib_id}" == "null" ]]
    then
        break
    fi

    case "${ib_mode}" in
        (l)
            source "${operators}/inline_search_pools.zsh"
        ;;
        (p)
            source "${operators}/inline_search_posts.zsh"
        ;;
        (t)
            source "${operators}/inline_search_tags.zsh"
        ;;
    esac

    results+=(${result})
done

results="$(jq -sc <<< ${results[@]})"

if [[ -n "${ib_autopaging}" ]]
then
    next_offset=$((inline_page + 1))
fi

rmdir "${cache}/${ib_hash}.lock"
