#!/usr/bin/env zsh
#
# Copyright (C) 2024-2026 Maria Lisina
# Copyright (C) 2024-2026 Danil Lisin
# SPDX-License-Identifier: Apache-2.0

if [[ "${__aliases_env}" != "0" ]]
then
    env -i PATH="${PATH}" __aliases_env=0 "${0}" ${@}
    exit ${?}
fi

exec 2> /dev/null

set -e
umask 77

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
        "\n\nUsage: ${0} [action] [ID] [alias ID]" \
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
        "\nUpdate your Z Shell or get a version with all required modules"
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
        "\nUpdate your BusyBox or get a version with all required functions"
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
            echo "You must specify target user ID" \
                "\nSee '${0} help'"
            exit 1
        fi
    ;;
esac

if ! [[ -f "${list}" ]]
then
    < "${list}.default" > "${list}"
fi

case "${action}" in
    (list)
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
            alias_id="${1}"

            if ! test ${alias_id} -gt 0
            then
                echo "Illegal user ID ${alias_id}"
                exit 1
            fi

            shift
        else
            echo "You must specify alias ID" \
                "\nSee '${0} help'"
            exit 1
        fi

        if alias="$(grep -x "${user_id} .*" "${list}")"
        then
            alias_id="$(cut -F 2 <<< "${alias}")"

            echo "User ID ${user_id} is already aliased to ${alias_id}"
            exit 1
        fi

        printf "%s %s\n" "${user_id}" "${alias_id}" >> "${list}"
    ;;
    (del)
        sed -i "/^${user_id} .*$/d" "${list}"
    ;;
    (reset)
        < "${list}.default" > "${list}"
    ;;
esac
