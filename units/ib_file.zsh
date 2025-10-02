# Copyright (C) 2024-2025 Maria Lisina
# Copyright (C) 2024-2025 Danil Lisin
# SPDX-License-Identifier: Apache-2.0

if [[ -f "${ib_file}" && "${cache_mode}" != "none" ]]
then
    ib_ctime=$(strftime %s)
    ib_mtime=$(stat +mtime "${ib_file}")

    if [[ $((ib_ctime - ib_mtime)) -le ${cache_time} ]]
    then
        return 0
    fi
fi

if [[ -d "${user_config}/${ib_config}" ]]
then
    . "${units}/ib_token.zsh"

    if [[ -n "${output_text}" ]]
    then
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

if ! curl --connect-timeout ${connrefused_timeout} \
    --data-urlencode "${ib_dfield1}" \
    --data-urlencode "${ib_dfield2}" \
    --data-urlencode "${ib_dfield3}" \
    --data-urlencode "${ib_dfield4}" \
    --data-urlencode "${ib_dfield5}" \
    --data-urlencode "${ib_dfield6}" \
    --data-urlencode "${ib_limit}" \
    --data-urlencode "${ib_page}" \
    --data-urlencode "${ib_query}" \
    --get \
    --header "${ib_headers}" \
    --max-time ${external_timeout} \
    --output "${ib_file}" \
    --proxy "${external_proxy}" \
    --retry 1 \
    --retry-connrefused \
    --retry-max-time $((external_timeout - connrefused_timeout)) \
    --silent \
    --user-agent "${useragent}" \
    "${ib_data_url}"
then
    output_title="An error occurred"
    output_text="Failed to access ${ib_name} API"
    notification_text="${output_text}"

    log_text="ib_file (${update_id}): ${output_text}"
    . "${units}/log.zsh"

    next_offset=${inline_page:-0}

    rm -f "${ib_file}"
    return 0
fi

if ! jq -e '.' "${ib_file}" > /dev/null
then
    output_title="An error occurred"
    output_text="An unknown error occurred"
    notification_text="${output_text}"

    log_text="ib_file (${update_id}): ${output_text}"
    . "${units}/log.zsh"

    rm -f "${ib_file}"
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
    else
        output_text="Try different post ID or MD5 hash"
    fi

    notification_text="${output_text}"
    rm -f "${ib_file}"
fi
