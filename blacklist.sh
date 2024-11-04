#!/usr/bin/env dash
#
# Copyright (C) 2024 Maria Lisina
# Copyright (C) 2024 Danil Lisin
# SPDX-License-Identifier: Apache-2.0
#
# Run this software with `env -i` to avoid variable conflict

set -e
umask 77

config="${0%/*}/config"
list="${config}/blacklist"

if [ -n "${1}" ]
then
    action="${1}"

    case "${action}" in
        (help)
            help=0
        ;;
        (show)
            show=0
        ;;
        (add | del)
        ;;
        (*)
            echo "Unrecognized action ${action}" \
                "\nSee '${0} help'"
            exit 1
        ;;
    esac

    shift
else
    help=0
fi

if [ -n "${help}" ]
then
    echo "Blacklist Manager" \
        "\n\nUsage: ${0} [action] [IDs]" \
        "\n\nActions:" \
        "\n  help\t\tShow help information" \
        "\n  show\t\tShow list entries" \
        "\n  add\t\tAdd user IDs to the list" \
        "\n  del\t\tRemove user IDs from the list"
    exit 0
fi

for required in busybox
do
    if ! command -v ${required} > /dev/null
    then
        missing="${missing} ${required}"
    fi
done

if [ -n "${missing}" ]
then
    echo "Missing dependencies:${missing}" \
        "\nFor more information follow: https://command-not-found.com/"
    exit 1
fi

for function in cat grep mkdir sed
do
    if busybox ${function} --help > /dev/null 2>&1
    then
        alias ${function}="busybox ${function}"
    else
        missing="${missing} ${function}"
    fi
done

if [ -n "${missing}" ]
then
    echo "Missing BusyBox functions:${missing}" \
        "\nUpdate your BusyBox or get a version with all the required functions"
    exit 1
fi

if [ -n "${show}" ]
then
    if [ -f "${list}" ]
    then
        cat "${list}"
    fi

    exit 0
fi

if [ ${#} -eq 0 ]
then
    echo "You must specify at least one user ID" \
        "\nSee '${0} help'"
    exit 1
fi

mkdir -p "${config}"

for user_id in ${@}
do
    if ! test ${user_id} -gt 0 > /dev/null 2>&1
    then
        echo "Illegal user ID ${user_id}"
    fi

    case "${action}" in
        (add)
            if [ -f "${list}" ] && grep -qwFe "${user_id}" "${list}"
            then
                echo "User ID ${user_id} is already in the blacklist"
            else
                printf "%s\n" "${user_id}" >> "${list}"
            fi
        ;;
        (del)
            if [ -f "${list}" ]
            then
                sed -e "s/${user_id}//" -e '/^$/d' -i "${list}"
            fi
        ;;
    esac
done
