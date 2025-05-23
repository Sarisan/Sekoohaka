#!/usr/bin/env zsh
#
# Copyright (C) 2024-2025 Maria Lisina
# Copyright (C) 2024-2025 Danil Lisin
# SPDX-License-Identifier: Apache-2.0
#
# Run this software with `env -i` to avoid variable conflict

set -e
umask 77
exec 2> /dev/null

dir="${0%/*}"
files="${dir}/files"
list="${files}/whitelist.txt"

if [[ -n "${1}" ]]
then
    action="${1}"

    case "${action}" in
        (help)
            help=0
        ;;
        (list | add | del | reset)
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

if [[ -n "${help}" ]]
then
    echo "Whitelist Manager" \
        "\n\nUsage: ${0} [action] [ID]" \
        "\n\nActions:" \
        "\n  help\t\tShow help information" \
        "\n  list\t\tList whitelist entries" \
        "\n  add\t\tAdd user ID to the whitelist" \
        "\n  del\t\tRemove user ID from the whitelist" \
        "\n  reset\t\tRemove all whitelist entries"
    exit 0
fi

for module in zsh/files
do
    if ! zmodload ${module}
    then
        failed="${failed} ${module}"
    fi
done

if [[ -n "${failed}" ]]
then
    echo "Failed to load Z Shell modules:${failed}" \
        "\nUpdate your Z Shell or get a version with all the required modules"
    exit 1
fi

for required in busybox
do
    if ! command -v ${required} > /dev/null
    then
        missing="${missing} ${required}"
    fi
done

if [[ -n "${missing}" ]]
then
    echo "Missing dependencies:${missing}" \
        "\nFor more information follow: https://command-not-found.com/"
    exit 1
fi

for function in grep sed
do
    if busybox ${function} --help > /dev/null
    then
        alias ${function}="busybox ${function}"
    else
        missing="${missing} ${function}"
    fi
done

if [[ -n "${missing}" ]]
then
    echo "Missing BusyBox functions:${missing}" \
        "\nUpdate your BusyBox or get a version with all the required functions"
    exit 1
fi

case "${action}" in
    (add | del)
        if [[ -n "${1}" ]]
        then
            user_id="${1}"

            if ! test ${user_id} -gt 0
            then
                echo "Illegal user ID ${user_id}"
                exit 1
            fi

            shift
        else
            echo "You must specify the user ID" \
                "\nSee '${0} help'"
            exit 1
        fi
    ;;
esac

case "${action}" in
    (list)
        if [[ -s "${list}" ]]
        then
            < "${list}"
        fi
    ;;
    (add)
        if [[ -s "${list}" ]] && grep -qxe "${user_id}" "${list}"
        then
            echo "User ID ${user_id} is already in the whitelist"
            exit 1
        fi

        printf "%s\n" "${user_id}" >> "${list}"
    ;;
    (del)
        if [[ -s "${list}" ]]
        then
            sed -e "s/^${user_id}$//" -e '/^$/d' -i "${list}"
        fi
    ;;
    (reset)
        < "${list}.default" > "${list}"
    ;;
esac
