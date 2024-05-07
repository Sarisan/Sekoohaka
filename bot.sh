#!/usr/bin/env dash
#
# Copyright (C) 2024 Maria Lisina
# Copyright (C) 2024 Danil Lisin
# SPDX-License-Identifier: Apache-2.0
#
# Run this software with `env -i` to avoid variable conflict

set -e
umask 77

for required in busybox curl jq recode
do
    if ! command -v ${required} > /dev/null
    then
        missing="${missing} ${required}"
    fi
done

if [ -n "${missing}" ]
then
    echo "Missing dependencies:${missing}\n" \
        "For more information follow: https://command-not-found.com/"
    exit 1
fi

dir="${0%/*}"
cache="${dir}/cache"
config="${dir}/config"
commands="${dir}/commands"
functions="${dir}/functions"
offset="-1"

if [ -n "${1}" ]
then
    while getopts ha:s:p: options
    do
        case "${options}" in
            (h)
                help=0
            ;;
            (a)
                address="${OPTARG}"
            ;;
            (s)
                max_size=${OPTARG}
            ;;
            (p)
                proxy="${OPTARG}"
            ;;
            (*)
                echo "See '${0} -h'"
                exit 1
            ;;
        esac
    done

    shift $((OPTIND - 1))
else
    help=0
fi

if [ -n "${help}" ]
then
    echo "Sekoohaka Bot" \
        "\n\nUsage: ${0} [options] [token]" \
        "\n\nOptions:" \
        "\n  -h\t\tShow help information" \
        "\n  -a <addr>\tTelegram Bot API address, default: api.telegram.org" \
        "\n  -s <size>\tMax file size allowed to send with URL, default: 10485760" \
        "\n  -p <addr>\tProxy address for external requests"
    exit 0
fi

if [ -z "${address}" ]
then
    address="https://api.telegram.org"
fi

if [ -n "${max_size}" ]
then
    if ! test ${max_size} -gt 0 > /dev/null 2>&1
    then
        echo "Illegal file size"
        exit 1
    fi
else
    max_size=10485760
fi

if [ -n "${1}" ]
then
    token="${1}"
    shift
fi

if [ -n "${1}" ]
then
    echo "Unrecognized action ${1}. See '${0} -h'"
    exit 1
fi

until [ -n "${token}" ]
do
    read -p "Telegram Bot API Token: " -r token
done

for function in $(busybox --list)
do
    if ! type ${function} | busybox grep -q "shell builtin"
    then
        alias ${function}="busybox ${function}"
    fi
done

alias stop="wait && exit"
alias htmlescape="sed -e 's/</\&#60;/g' -e 's/>/\&#62;/g'"
alias urlencode="jq -Rr @uri"

for ascii in $(seq 33 126)
do
    ascii_table="${ascii_table} $(printf "%b" "\0$(printf "%o" ${ascii})")"
done

rm -fr "${cache}"
mkdir -p "${cache}"
mkdir -p "${config}"

curl --get \
    --max-time 10 \
    --output "${cache}/getMe.json" \
    --show-error \
    --silent \
    "${address}/bot${token}/getMe"

if ! jq -e '.' "${cache}/getMe.json" > /dev/null
then
    cat "${cache}/getMe.json"
    exit 1
fi

username="$(jq -r '.result.username' "${cache}/getMe.json")"

if [ "${username}" = "null" ]
then
    echo "Failed to authorize the bot"
    exit 1
fi

echo "Bot: ${username}"

while trap 'stop 0' INT TERM
do
    if ! curl --data "offset=${offset}" \
        --get \
        --output "${cache}/getUpdates.json" \
        --silent \
        "${address}/bot${token}/getUpdates"
    then
        continue
    fi

    if ! update_id="$(jq -r '.result.[0].update_id' "${cache}/getUpdates.json")"
    then
        continue
    fi

    if [ "${update_id}" != "null" ]
    then
        update="${cache}/${update_id}.json"

        if ! jq '.result.[0]' "${cache}/getUpdates.json" > "${update}"
        then
            continue
        fi

        for command in "${commands}"/*
        do
            . "${command}" &
        done

        offset="$((update_id + 1))"
    fi
done
