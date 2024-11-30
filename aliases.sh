#!/usr/bin/env dash
#
# Copyright (C) 2024 Maria Lisina
# Copyright (C) 2024 Danil Lisin
# SPDX-License-Identifier: Apache-2.0
#
# Run this software with `env -i` to avoid variable conflict

set -e
umask 77

lists="${0%/*}/lists"
list="${lists}/aliases.txt"

if [ -n "${1}" ]
then
    action="${1}"

    case "${action}" in
        (help)
            help=0
        ;;
        (show | add | del | reset)
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
    echo "Aliases Manager" \
        "\n\nUsage: ${0} [action] [ID] [alias]" \
        "\n\nActions:" \
        "\n  help\t\tShow help information" \
        "\n  show\t\tShow all aliases" \
        "\n  add\t\tAdd user ID alias" \
        "\n  del\t\tRemove user ID alias" \
        "\n  reset\t\tRemove all aliases"
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

for function in cat mkdir sed
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

case "${action}" in
    (add | del)
        if [ -n "${1}" ]
        then
            user_id="${1}"

            if ! test ${user_id} -gt 0 > /dev/null 2>&1
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
    (show)
        if [ -s "${list}" ]
        then
            cat "${list}"
        fi
    ;;
    (add)
        if [ -n "${1}" ]
        then
            alias="${1}"
            shift
        else
            echo "You must specify the alias name" \
                "\nSee '${0} help'"
            exit 1
        fi

        if [ -s "${list}" ]
        then
            set -- $(cat "${list}")

            while [ ${#} -ge 2 ]
            do
                if [ "${1}" = "${user_id}" ]
                then
                    echo "User ID ${user_id} already has an alias ${2}"
                    exit 1
                fi

                shift 2
            done
        fi

        printf "%s %s\n" "${user_id}" "${alias}" >> "${list}"
    ;;
    (del)
        if [ -s "${list}" ]
        then
            sed -e "s/^${user_id} .*$//" -e '/^$/d' -i "${list}"
        fi
    ;;
    (reset)
        cat "${list}.default" > "${list}"
    ;;
esac
