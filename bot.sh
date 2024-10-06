#!/usr/bin/env dash
#
# Copyright (C) 2024 Maria Lisina
# Copyright (C) 2024 Danil Lisin
# SPDX-License-Identifier: Apache-2.0
#
# Run this software with `env -i` to avoid variable conflict

set -e
umask 77

version="2.3.1"
dir="${0%/*}"
cache="${dir}/cache/${$}"
config="${dir}/config"
modules="${dir}/modules"
submodules="${dir}/submodules"
units="${dir}/units"
offset=-1

if [ -n "${1}" ]
then
    while getopts hla:s:g:r:m:t:vi:e:d:n:x: options
    do
        case "${options}" in
            (h)
                help=0
            ;;
            (l)
                api_local=0
            ;;
            (a)
                api_address="${OPTARG}"
            ;;
            (s)
                size_limit=${OPTARG}
            ;;
            (g)
                shorts_limit=${OPTARG}
            ;;
            (r)
                inline_limit=${OPTARG}
            ;;
            (m)
                caching_mode=${OPTARG}
            ;;
            (t)
                caching_time=${OPTARG}
            ;;
            (v)
                cache_removal=0
            ;;
            (i)
                internal_timeout=${OPTARG}
            ;;
            (e)
                external_timeout=${OPTARG}
            ;;
            (d)
                head_timeout=${OPTARG}
            ;;
            (n)
                internal_proxy="${OPTARG}"
            ;;
            (x)
                external_proxy="${OPTARG}"
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
        "\n  -l\t\tSame as -a 127.0.0.1:8081 -s 20971520" \
        "\n  -a <addr>\tTelegram Bot API address, default: api.telegram.org" \
        "\n  -s <size>\tMax file size allowed to send with URL, default: 10 MiB" \
        "\n  -r <num>\tInline results limit, max: 50, default: 10" \
        "\n  -g <num>\tShortcuts storage limit, default: 100" \
        "\n  -m <mode>\tCaching mode, default: normal" \
        "\n  -t <secs>\tCaching time, default: 300 secs" \
        "\n  -v\t\tDo not remove cache automatically" \
        "\n  -i <secs>\tTelegram Bot API connetion timeout, default: 10 secs" \
        "\n  -e <secs>\tImage Boards API connetion timeout, default: 5 secs" \
        "\n  -d <secs>\tHead request connetion timeout, default: 2 secs" \
        "\n  -n <addr>\tProxy server for Telegram Bot API" \
        "\n  -x <addr>\tProxy server for Image Boards API" \
        "\n\nCaching modes:" \
        "\n  none\t\tNo caching" \
        "\n  normal\tCache inline results and posts" \
        "\n  advanced\tExtract posts cache from inline results"
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

if [ -n "${api_local}" ]
then
    api_address="${api_address:-127.0.0.1:8081}"
    size_limit=${size_limit:-20971520}
fi

if [ -z "${api_address}" ]
then
    api_address="https://api.telegram.org"
fi

if [ -n "${size_limit}" ]
then
    if ! test ${size_limit} -gt 0 > /dev/null 2>&1
    then
        echo "Illegal file size"
        exit 1
    fi
else
    size_limit=10485760
fi

if [ -n "${shorts_limit}" ]
then
    if ! test ${shorts_limit} -gt 0 > /dev/null 2>&1
    then
        echo "Illegal shortcuts limit number"
        exit 1
    fi
else
    shorts_limit=100
fi

if [ -n "${inline_limit}" ]
then
    if ! test ${inline_limit} -gt 0 > /dev/null 2>&1
    then
        echo "Illegal inline results limit number"
        exit 1
    fi

    if [ ${inline_limit} -gt 50 ]
    then
        inline_limit=50
    fi
else
    inline_limit=10
fi

if [ -n "${caching_mode}" ]
then
    case "${caching_mode}" in
        (none | normal | advanced)
        ;;
        (*)
            echo "Unrecognized caching mode ${caching_mode}. See '${0} -h'"
            exit 1
        ;;
    esac
else
    caching_mode=normal
fi

if [ -n "${caching_time}" ]
then
    if ! test ${caching_time} -gt 0 > /dev/null 2>&1
    then
        echo "Illegal caching time"
        exit 1
    fi
else
    caching_time=300
fi

if [ -n "${internal_timeout}" ]
then
    if ! test ${internal_timeout} -gt 0 > /dev/null 2>&1
    then
        echo "Illegal Telegram Bot API timeout"
        exit 1
    fi
else
    internal_timeout=10
fi

if [ -n "${external_timeout}" ]
then
    if ! test ${external_timeout} -gt 0 > /dev/null 2>&1
    then
        echo "Illegal Image Boards API timeout"
        exit 1
    fi
else
    external_timeout=5
fi

if [ -n "${head_timeout}" ]
then
    if ! test ${head_timeout} -gt 0 > /dev/null 2>&1
    then
        echo "Illegal head request timeout"
        exit 1
    fi
else
    head_timeout=2
fi

if [ -n "${1}" ]
then
    api_token="${1}"
    shift
fi

if [ -n "${1}" ]
then
    echo "Unrecognized action ${1}. See '${0} -h'"
    exit 1
fi

until [ -n "${api_token}" ]
do
    read -p "Telegram Bot API Token: " -r api_token
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
    --max-time ${internal_timeout} \
    --output "${cache}/getMe.json" \
    --proxy "${internal_proxy}" \
    --show-error \
    --silent \
    "${api_address}/bot${api_token}/getMe"

if ! jq -e '.' "${cache}/getMe.json" > /dev/null
then
    echo "Failed to get the bot information"
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
        --proxy "${internal_proxy}" \
        --silent \
        "${api_address}/bot${api_token}/getUpdates"
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

        if ! jq -c '.result.[0]' "${cache}/getUpdates.json" > "${update}"
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
