# Copyright (C) 2024-2026 Maria Lisina
# Copyright (C) 2024-2026 Danil Lisin
# SPDX-License-Identifier: Apache-2.0

if [[ -z "${ib_login}" ]]
then
    if [[ -f "${login_file}" ]]
    then
        ib_login="$(< "${login_file}")"
    else
        output_text="You must specify ${ib_login_word} and ${ib_key_word}"
        return
    fi
fi

if [[ -z "${ib_key}" ]]
then
    if [[ -f "${key_file}" ]]
    then
        ib_key="$(< "${key_file}")"
    else
        output_text="You must specify ${ib_key_word}"
        return
    fi
fi

if ! mkdir -p "${auth_dir}"
then
    output_text="Failed to create user config"
    return
fi

case "${ib_board}" in
    (a|d)
        source "${auth}/donmai.zsh"
    ;;
    (g)
        source "${auth}/gelbooru.zsh"
    ;;
    (i|s)
        source "${auth}/sankakucomplex.zsh"
    ;;
    (k|y)
        source "${auth}/moebooru.zsh"
    ;;
esac

if [[ -z "${output_text}" ]]
then
    printf "%s\n" "${ib_login}" > "${login_file}"
    printf "%s\n" "${ib_key}" > "${key_file}"
else
    for user_data_dir in "${auth_dir}" "${user_config}"
    do
        user_data=($(ls -1 "${user_data_dir}"))

        if [[ ${#user_data} -eq 0 ]]
        then
            rmdir "${user_data_dir}"
        fi
    done
fi
