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
list="${files}/aliases.txt"

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
    echo "Aliases Manager" \
        "\n\nUsage: ${0} [action] [ID] [alias]" \
        "\n\nActions:" \
        "\n  help\t\tShow help information" \
        "\n  list\t\tList all aliases" \
        "\n  add\t\tAdd user ID alias" \
        "\n  del\t\tRemove user ID alias" \
        "\n  reset\t\tRemove all aliases"
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
            echo "You must specify the target user ID" \
                "\nSee '${0} help'"
            exit 1
        fi
    ;;
esac

case "${action}" in
    (list)
        if ! [[ -s "${list}" ]]
        then
            exit 0
        fi

        list=($(< "${list}"))

        while [[ ${#list} -ge 2 ]]
        do
            printf "%s --> %s\n" "${list[1]}" "${list[2]}"
            shift 2 list
        done
    ;;
    (add)
        if [[ -n "${1}" ]]
        then
            alias_name="${1}"
            shift
        else
            echo "You must specify the alias name" \
                "\nSee '${0} help'"
            exit 1
        fi

        if [[ -s "${list}" ]] && alias="$(grep -xe "${user_id} .*" "${list}")"
        then
            alias_name="$(printf "%s" "${alias}" | cut -d ' ' -f 2)"

            echo "User ID ${user_id} already has an alias ${alias_name}"
            exit 1
        fi

        printf "%s %s\n" "${user_id}" "${alias_name}" >> "${list}"
    ;;
    (del)
        if [[ -s "${list}" ]]
        then
            sed -e "s/^${user_id} .*$//" -e '/^$/d' -i "${list}"
        fi
    ;;
    (reset)
        < "${list}.default" > "${list}"
    ;;
esac
