# Copyright (C) 2024-2025 Maria Lisina
# Copyright (C) 2024-2025 Danil Lisin
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
        . "${submodules}/inline_help.sh"
        return 0
    ;;
esac

ib_lock=0
. "${units}/ib_search.sh"

if [ -n "${output_text}" ]
then
    results="$(jq --null-input --compact-output \
        --arg id "${query_id}" \
        --arg title "${output_title}" \
        --arg text "${output_text}" \
        --arg description "${output_text}" \
        '[{"type": "article", "id": $id, "title": $title, "input_message_content": {"message_text": $text}, "description": $description}]')"

    return 0
fi

results="[]"
array_count=0

while [ -n "${array_count}" ]
do
    ib_id="$(jq -r ".${ib_iarray}[${array_count}].${ib_iid}" "${ib_file}")"

    if [ "${ib_id}" = "null" ]
    then
        break
    fi

    case "${ib_mode}" in
        (l)
            . "${submodules}/inline_search_pools.sh"
        ;;
        (p)
            . "${submodules}/inline_search_posts.sh"
        ;;
        (t)
            . "${submodules}/inline_search_tags.sh"
        ;;
    esac

    results="$(printf "%s" "${results}" | jq -c ".[${array_count}] += ${result}")"
    array_count=$((array_count + 1))
done

if [ -n "${ib_autopaging}" ]
then
    next_offset=$((inline_page + 1))
fi
