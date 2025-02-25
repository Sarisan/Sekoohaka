#!/usr/bin/env dash
#
# Copyright (C) 2024-2025 Maria Lisina
# Copyright (C) 2024-2025 Danil Lisin
# SPDX-License-Identifier: Apache-2.0
#
# Run this software with `env -i` to avoid variable conflict

set -e
umask 77

dir="${0%/*}"
units="${dir}/units"

if [ -n "${1}" ]
then
    action="${1}"

    case "${action}" in
        (help)
            help=0
        ;;
        (*)
            echo "Unrecognized action ${action}" \
                "\nSee '${0} help'"
            exit 1
        ;;
    esac

    shift
fi

if [ -n "${help}" ]
then
    echo "List Supported Image Boards" \
        "\n\nUsage: ${0} [action]" \
        "\n\nActions:" \
        "\n  help\t\tShow help information"
    exit 0
fi

for ascii in $(seq 33 126)
do
    ascii_table="${ascii_table} $(printf "%b" "\0$(printf "%o" ${ascii})")"
done

for ib_board in ${ascii_table}
do
    . "${units}/ib_config.sh"
    . "${units}/ib_authconfig.sh"

    if [ -n "${ib_name}" ]
    then
        printf "%s\n" "${ib_name}"

        if [ -n "${ib_config}" ]
        then
            ib_features="${ib_features} authorization"
        fi

        for ib_mode in ${ascii_table}
        do
            . "${units}/ib_config.sh"

            if [ -n "${ib_data_url}" ]
            then
                case "${ib_mode}" in
                    (l)
                        ib_feature="pools"
                    ;;
                    (p)
                        ib_feature="posts"
                    ;;
                    (t)
                        ib_feature="tags"
                    ;;
                esac

                ib_features="${ib_features} ${ib_feature}"
            fi

            unset ib_data_url
        done

        if [ -n "${ib_features}" ]
        then
            printf "  Features:%s\n" "${ib_features}"
        else
            printf "  Features: none\n"
        fi

        if [ -n "${ib_url}" ]
        then
            printf "  URL: %s\n" "${ib_url}"
        else
            printf "  URL: none\n"
        fi

        if [ -n "${ib_board}" ]
        then
            printf "  Alias: %c\n" "${ib_board}"
        else
            printf "  Alias: none\n"
        fi

        printf '\n'
    fi

    unset ib_name ib_config ib_feature ib_features
done
