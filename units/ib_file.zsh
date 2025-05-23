# Copyright (C) 2024-2025 Maria Lisina
# Copyright (C) 2024-2025 Danil Lisin
# SPDX-License-Identifier: Apache-2.0

until mkdir "${cache}/${ib_hash}.lock"
do
    sleep 1
done

ib_file="${cache}/${ib_hash}.json"
dump=(${dump[@]} ${ib_file##*/})

if [[ -f "${ib_file}" && "${cache_mode}" != "none" ]]
then
    ib_ctime=$(strftime %s)
    ib_mtime=$(stat +mtime "${ib_file}")

    if [[ $((ib_ctime - ib_mtime)) -le $((cache_time - 15)) ]]
    then
        rmdir "${cache}/${ib_hash}.lock"
        return 0
    fi
fi

if [[ -n "${ib_config}" ]]
then
    . "${units}/ib_token.zsh"

    if [[ -n "${output_text}" ]]
    then
        rmdir "${cache}/${ib_hash}.lock"
        return 0
    fi
fi

if [[ -n "${ib_limit}" ]]
then
    ib_limit="${ib_dlimit}=${ib_limit}"
fi

if [[ -n "${ib_page}" ]]
then
    ib_page="${ib_dpage}=$((ib_page + ib_ioffset))"
fi

if [[ -n "${ib_query}" ]]
then
    ib_query="${ib_dquery}=${ib_query}"
fi

rm -f "${ib_file}"

if ! curl --data-urlencode "${ib_dfield1}" \
    --data-urlencode "${ib_dfield2}" \
    --data-urlencode "${ib_dfield3}" \
    --data-urlencode "${ib_dfield4}" \
    --data-urlencode "${ib_dfield5}" \
    --data-urlencode "${ib_dfield6}" \
    --data-urlencode "${ib_limit}" \
    --data-urlencode "${ib_page}" \
    --data-urlencode "${ib_query}" \
    --get \
    --header "${ib_header}" \
    --max-time ${external_timeout} \
    --output "${ib_file}" \
    --proxy "${external_proxy}" \
    --silent \
    --user-agent "${useragent}" \
    "${ib_data_url}"
then
    output_title="An error occurred"
    output_text="Failed to access ${ib_name} API"
    notification_text="${output_text}"
    log_text="ib_file (${update_id}): ${output_text}"

    next_offset=${inline_page:-0}

    . "${units}/log.zsh"
    . "${units}/dump.zsh"

    rm -fr "${ib_file}" "${cache}/${ib_hash}.lock"
    return 0
fi

if ! jq -e '.' "${ib_file}" > /dev/null
then
    output_title="An error occurred"
    output_text="An unknown error occurred"
    notification_text="${output_text}"
    log_text="ib_file (${update_id}): ${output_text}"

    . "${units}/log.zsh"
    . "${units}/dump.zsh"

    rm -fr "${ib_file}" "${cache}/${ib_hash}.lock"
    return 0
fi

if ! jq -e ".${ib_iarray}[0]|has(\"${ib_iid}\")" "${ib_file}" > /dev/null
then
    if [[ -n "${inline_options}" && -n "${offset}" ]]
    then
        output_title="End of results"
    else
        output_title="No results found"
    fi

    if [[ -n "${inline_options}" ]]
    then
        case "${ib_mode}" in
            (l)
                output_text="Try different page or pool name"
            ;;
            (p)
                output_text="Try different page or tags"
            ;;
            (t)
                output_text="Try different page or tag name"
            ;;
        esac
    elif [[ -n "${ib_parent}" ]]
    then
        output_text="No results found"
    else
        output_text="Try different post ID or MD5 hash"
    fi

    notification_text="${output_text}"

    rm -f "${ib_file}"
fi

rmdir "${cache}/${ib_hash}.lock"
