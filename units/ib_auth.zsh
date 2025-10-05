# Copyright (C) 2024-2025 Maria Lisina
# Copyright (C) 2024-2025 Danil Lisin
# SPDX-License-Identifier: Apache-2.0

if [[ -z "${ib_login}" ]]
then
    if [[ -f "${login_file}" ]]
    then
        ib_login="$(< "${login_file}")"
    else
        output_text="You must specify ${ib_login_word} and ${ib_key_word}"
        return 0
    fi
fi

if [[ -z "${ib_key}" ]]
then
    if [[ -f "${key_file}" ]]
    then
        ib_key="$(< "${key_file}")"
    else
        output_text="You must specify ${ib_key_word}"
        return 0
    fi
fi

if ! mkdir -p "${auth_dir}"
then
    output_text="Failed to create user config"
    return 0
fi

case "${ib_board}" in
    (a|d)
        . "${auth}/donmai.zsh"
    ;;
    (g)
        . "${auth}/gelbooru.zsh"
    ;;
    (i|s)
        . "${auth}/sankakucomplex.zsh"
    ;;
    (k|y)
        . "${auth}/moebooru.zsh"
    ;;
esac

if [[ -z "${output_text}" ]]
then
    printf "%s\n" "${ib_login}" > "${login_file}"
    printf "%s\n" "${ib_key}" > "${key_file}"
fi

auth_data=($(ls -1 "${auth_dir}"))

if [[ ${#auth_data} -eq 0 ]]
then
    rmdir "${auth_dir}"
fi
