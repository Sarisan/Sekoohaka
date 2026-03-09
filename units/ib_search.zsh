# Copyright (C) 2024-2026 Maria Lisina
# Copyright (C) 2024-2026 Danil Lisin
# SPDX-License-Identifier: Apache-2.0

if [[ -n "${1}" ]]
then
    ib_board="${1}"

    source "${units}/ib_config.zsh"
    source "${units}/ib_authconfig.zsh"

    if [[ -z "${ib_data_url}" ]]
    then
        output_title="Invalid arguments"
        output_text="Unsupported Image Board"

        return
    fi

    shift
else
    output_title="Invalid arguments"
    output_text="You must specify Image Board"

    return
fi

if test "${1}" -gt 0
then
    inline_page=${1}
    shift
else
    inline_page=1
    set -- -a ${@}
fi

if [[ -n "${offset}" ]]
then
    inline_page=${offset}
fi

if [[ -n "${1}" ]]
then
    search_query="${@}"

    if ! zparseopts -D -F -K -- \
        a=ib_autopaging \
        m=ib_metadata \
        p=ib_preview \
        q=ib_quick
    then
        output_title="Invalid arguments"
        output_text="Unsupported options"

        return
    fi
fi

if [[ -n "${1}" ]]
then
    ib_query="${@}"
    shift ${#}
fi

ib_limit=${inline_limit}
ib_page=${inline_page}
