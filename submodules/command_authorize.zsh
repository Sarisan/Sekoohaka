# Copyright (C) 2024-2025 Maria Lisina
# Copyright (C) 2024-2025 Danil Lisin
# SPDX-License-Identifier: Apache-2.0

if [[ -n "${1}" ]]
then
    ib_board="${1}"
    . "${units}/ib_config.zsh"
    . "${units}/ib_authconfig.zsh"

    if [[ -z "${ib_auth}" ]]
    then
        output_text="Unsupported Image Board"
        return 0
    fi

    shift
else
    output_text="You must specify the Image Board"
    return 0
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

. "${units}/ib_lock.zsh"

if [[ -z "${output_text}" ]]
then
    output_text="Authorized successfully"
fi
