# Copyright (C) 2024-2025 Maria Lisina
# Copyright (C) 2024-2025 Danil Lisin
# SPDX-License-Identifier: Apache-2.0

if [[ -n "${1}" ]]
then
    ib_board="${1}"
    . "${units}/ib_authconfig.zsh"

    if [[ -z "${ib_config}" ]]
    then
        output_text="Unsupported image board"
        return 0
    fi

    shift
else
    output_text="You must specify the image board"
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
    if [[ -n "${ib_noauth}" ]]
    then
        output_text="Authorization cannot be verified, make sure you provided the correct credentials"
    else
        output_text="Authorized successfully"
    fi
fi
