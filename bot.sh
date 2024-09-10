#!/usr/bin/env dash
#
# Copyright (C) 2024 Maria Lisina
# Copyright (C) 2024 Danil Lisin
# SPDX-License-Identifier: Apache-2.0
#
# Run this software with `env -i` to avoid variable conflict

set -e
umask 77

version="2.1"
dir="${0%/*}"
cache="${dir}/cache/${$}"
config="${dir}/config"
modules="${dir}/modules"
submodules="${dir}/submodules"
units="${dir}/units"
offset=-1

if [ -n "${1}" ]
then
    while getopts hla:s:i:e: options
    do
        case "${options}" in
            (h)
                help=0
            ;;
            (l)
                local=0
            ;;
            (a)
                address="${OPTARG}"
            ;;
            (s)
                size=${OPTARG}
            ;;
            (i)
                internal="${OPTARG}"
            ;;
            (e)
                external="${OPTARG}"
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
    echo "Sekoohaka Bot v${version}" \
        "\n\nUsage: ${0} [options] [token]" \
        "\n\nOptions:" \
        "\n  -h\t\tShow help information" \
        "\n  -l\t\tSame as -a localhost:8081 -s 20971520" \
        "\n  -a <addr>\tTelegram Bot API address, default: api.telegram.org" \
        "\n  -s <size>\tMax file size allowed to send with URL, default: 10485760" \
        "\n  -i <addr>\tInternal proxy address to interact with Telegram Bot API" \
        "\n  -e <addr>\tExternal proxy address to interact with anything else"
    exit 0
fi

for required in busybox curl jq recode
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

for function in base64 bc cat cut date find grep ls mkdir rm sed seq sha1sum sleep stat tr
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

if [ -n "${local}" ]
then
    address="${address:-127.0.0.1:8081}"
    size=${size:-20971520}
fi

if [ -z "${address}" ]
then
    address="https://api.telegram.org"
fi

if [ -n "${size}" ]
then
    if ! test ${size} -gt 0 > /dev/null 2>&1
    then
        echo "Illegal file size"
        exit 1
    fi
else
    size=10485760
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

alias parameter="cut -d ' ' -f"
alias enhash="sha1sum | parameter 1"
alias htmlescape="sed -e 's/</\&#60;/g' -e 's/>/\&#62;/g'"
alias urlencode="jq -Rr @uri"

for ascii in $(seq 33 126)
do
    ascii_table="${ascii_table} $(printf "%b" "\0$(printf "%o" ${ascii})")"
done

rm -fr "${cache}"
mkdir -p "${cache}"
mkdir -p "${config}"

echo "PID: ${$}"

curl --get \
    --max-time 10 \
    --output "${cache}/getMe.json" \
    --proxy "${internal}" \
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

while trap 'wait && exit 0' INT TERM
do
    if ! curl --data "offset=${offset}" \
        --get \
        --output "${cache}/getUpdates.json" \
        --proxy "${internal}" \
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

        for module in "${modules}"/*
        do
            . "${module}" &
        done

        offset=$((update_id + 1))
    fi
done
