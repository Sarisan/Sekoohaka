# Copyright (C) 2024-2025 Maria Lisina
# Copyright (C) 2024-2025 Danil Lisin
# SPDX-License-Identifier: Apache-2.0

if test "${1}" -gt 0
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

    while getopts "aqrw" inline_getopts
    do
        case "${inline_getopts}" in
            (a)
                shorts_autopaging=0
            ;;
            (q)
                shorts_quick=0
            ;;
            (r)
                shorts_reverse=0
            ;;
            (w)
                shorts_word=0
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
    shorts_query="${@}"
    shift ${#}
fi

if [ -d "${short_config}" ]
then
    if [ -n "${shorts_reverse}" ]
    then
        shorts_ls="-xtr"
    else
        shorts_ls="-xt"
    fi

    shorts="$(ls ${shorts_ls} "${short_config}")"
fi

set -- ${shorts}

if [ ${#} -eq 0 ]
then
    output_title="No shortcuts found"
    output_text="You have no saved shortcuts yet"

    return 0
fi

if [ -n "${shorts_query}" ]
then
    if [ -n "${shorts_word}" ]
    then
        shorts_grep="-lqwFe"
    else
        shorts_grep="-lqiFe"
    fi

    for short in ${@}
    do
        if grep ${shorts_grep} "${shorts_query}" "${short_config}/${short}"
        then
            query_shorts="${query_shorts} ${short}"
        fi
    done

    set -- ${query_shorts}
fi

if [ ${#} -ge $(((inline_page - 1) * inline_limit + 1)) ]
then
    shift $(((inline_page - 1) * inline_limit))
else
    if [ -n "${offset}" ]
    then
        output_title="End of results"
    else
        output_title="No results found"
    fi

    output_text="Try different page or query"
fi
