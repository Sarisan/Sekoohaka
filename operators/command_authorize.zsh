# Copyright (C) 2024-2026 Maria Lisina
# Copyright (C) 2024-2026 Danil Lisin
# SPDX-License-Identifier: Apache-2.0

command_authorize=0

if [[ -n "${1}" ]]
then
    ib_board="${1}"
    source "${units}/ib_authconfig.zsh"

    if [[ -z "${ib_auth}" ]]
    then
        output_text="Unsupported Image Board"
        return
    fi

    shift
else
    output_text="You must specify Image Board"
    return
fi

if [[ -n "${1}" ]]
then
    ib_login="${1}"
    shift
fi

if [[ -n "${1}" ]]
then
    ib_key="${1}"
    shift
fi

source "${units}/ib_lock.zsh"

if [[ -z "${output_text}" ]]
then
    output_text="Authorized successfully"
fi
