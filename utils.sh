#!/usr/bin/env dash
#
# Copyright (C) 2024 Maria Lisina
# Copyright (C) 2024 Danil Lisin
# SPDX-License-Identifier: Apache-2.0
#
# Run this software with `env -i` to avoid variable conflict

set -e
umask 77

dir="${0%/*}"
utils="${dir}/utils"

if [ -n "${1}" ]
then
    action="${1}"
    shift

    case "${action}" in
        (help)
            help=0
        ;;
        (aliases)
            . "${utils}/aliases.sh"
        ;;
        (blacklist)
            . "${utils}/blacklist.sh"
        ;;
        (whitelist)
            . "${utils}/whitelist.sh"
        ;;
        (list)
            . "${utils}/list.sh"
        ;;
        (*)
            echo "Unrecognized action or util ${action}" \
                "\nSee '${0} help'"
            exit 1
        ;;
    esac
else
    help=0
fi

if [ -n "${help}" ]
then
    echo "Sekoohaka Bot Utils" \
        "\n\nUsage: ${0} [util] [action]" \
        "\n\nActions:" \
        "\n  help\t\tShow help information" \
        "\n\nUtils:" \
        "\n  aliases\tAliases Manager" \
        "\n  blacklist\tBlacklist Manager" \
        "\n  whitelist\tWhitelist Manager" \
        "\n  list\t\tList Supported Image Boards"
    exit 0
fi
