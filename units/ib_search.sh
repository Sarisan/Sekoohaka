# Copyright (C) 2024-2025 Maria Lisina
# Copyright (C) 2024-2025 Danil Lisin
# SPDX-License-Identifier: Apache-2.0

if [ -n "${1}" ]
then
    ib_board="${1}"

    . "${units}/ib_config.sh"
    . "${units}/ib_authconfig.sh"

    if [ -z "${ib_data_url}" ]
    then
        output_title="Invalid arguments"
        output_text="Unsupported image board"

        return 0
    fi

    shift
else
    output_title="Invalid arguments"
    output_text="You must specify the image board"

    return 0
fi

if test "${1}" -gt 0 > /dev/null 2>&1
then
    inline_page=${1}
    shift
else
    inline_page=1
    set -- -a ${@}
fi

if [ -n "${offset}" ]
then
    inline_page=${offset}
fi

if [ -n "${1}" ]
then
    inline_query="${@}"

    while getopts ${inline_options} inline_getopts > /dev/null 2>&1
    do
        case "${inline_getopts}" in
            (a)
                ib_autopaging=0
            ;;
            (m)
                ib_metadata=0
            ;;
            (p)
                ib_preview=0
            ;;
            (q)
                ib_quick=0
            ;;
            (*)
                output_title="Invalid arguments"
                output_text="Unsupported options"

                return 0
            ;;
        esac
    done

    shift $((OPTIND - 1))
fi

if [ -n "${1}" ]
then
    ib_query="${@}"
    shift ${#}
fi

ib_limit=${inline_limit}
ib_page=${inline_page}

if [ -n "${ib_iwildcard}" ]
then
    ib_query="$(printf "%s" "${ib_query}" | sed "s/${ib_iwildcard}/\\\\${ib_iwildcard}/g" | tr '*' "${ib_iwildcard}")"
fi

ib_hash="$(printf "%s%s%s%s%s" "${user_id}" "${ib_mode}" "${ib_board}" "${ib_page}" "${ib_query}" | enhash)"
. "${units}/ib_file.sh"
