#!/usr/bin/env dash
#
# Copyright (C) 2024-2025 Maria Lisina
# Copyright (C) 2024-2025 Danil Lisin
# SPDX-License-Identifier: Apache-2.0
#
# Run this software with `env -i` to avoid variable conflict

set -e
umask 77

version="2.9-inadev"
dir="${0%/*}"
cache="${dir}/cache/${$}"
config="${dir}/config"
files="${dir}/files"
modules="${dir}/modules"
submodules="${dir}/submodules"
units="${dir}/units"
offset=-1

if [ -n "${1}" ]
then
    while getopts ha:lg:r:m:t:ci:e:d:n:x: options
    do
        case "${options}" in
            (h)
                help=0
            ;;
            (a)
                api_address="${OPTARG}"
            ;;
            (l)
                api_address="127.0.0.1:8081"
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
            (c)
                cache_clear=0
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
        "\n  -a <addr>\tTelegram Bot API address, default: api.telegram.org" \
        "\n  -l\t\tUse local Telegram Bot API, address: 127.0.0.1:8081" \
        "\n  -r <num>\tInline results limit, max: 50, default: 10" \
        "\n  -g <num>\tShortcuts storage limit, max: 10000, default: 100" \
        "\n  -m <mode>\tCaching mode, default: normal" \
        "\n  -t <secs>\tCaching time, max: 1000, default: 300 secs" \
        "\n  -c\t\tClear cache automatically" \
        "\n  -i <secs>\tTelegram Bot API connetion timeout, max: 10, default: 10 secs" \
        "\n  -e <secs>\tImage Boards API connetion timeout, max: 10, default: 5 secs" \
        "\n  -d <secs>\tHead request connetion timeout, max: 10, default: 2 secs" \
        "\n  -n <addr>\tProxy server for Telegram Bot API" \
        "\n  -x <addr>\tProxy server for Image Boards API" \
        "\n\nCaching modes:" \
        "\n  none\t\tNo caching" \
        "\n  normal\tCache inline results and posts" \
        "\n  advanced\tExtract posts cache from inline results" \
        "\n\nSupported Image Boards:" \
        "\n  Danbooru\t\t(https://danbooru.donmai.us/)" \
        "\n  Gelbooru\t\t(https://gelbooru.com/)" \
        "\n  Idol Complex\t\t(https://idol.sankakucomplex.com/)" \
        "\n  Konachan.com\t\t(https://konachan.com/)" \
        "\n  Sankaku Channel\t(https://chan.sankakucomplex.com/)" \
        "\n  yande.re\t\t(https://yande.re/)"
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

for function in base64 bc cat cut date find grep ls mkdir rm sed sha1sum sleep stat tr
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

if [ -z "${api_address}" ]
then
    api_address="https://api.telegram.org"
fi

if [ -n "${shorts_limit}" ]
then
    if ! test ${shorts_limit} -gt 0 > /dev/null 2>&1
    then
        echo "Illegal shortcuts limit number" \
            "\nSee '${0} -h'"
        exit 1
    fi

    if [ ${shorts_limit} -gt 10000 ]
    then
        shorts_limit=10000
    fi
else
    shorts_limit=100
fi

if [ -n "${inline_limit}" ]
then
    if ! test ${inline_limit} -gt 0 > /dev/null 2>&1
    then
        echo "Illegal inline results limit number" \
            "\nSee '${0} -h'"
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
            echo "Unrecognized caching mode ${caching_mode}" \
                "\nSee '${0} -h'"
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
        echo "Illegal caching time" \
            "\nSee '${0} -h'"
        exit 1
    fi

    if [ ${caching_time} -gt 1000 ]
    then
        caching_time=1000
    fi
else
    caching_time=300
fi

if [ -n "${internal_timeout}" ]
then
    if ! test ${internal_timeout} -gt 0 > /dev/null 2>&1
    then
        echo "Illegal Telegram Bot API timeout" \
            "\nSee '${0} -h'"
        exit 1
    fi

    if [ ${internal_timeout} -gt 10 ]
    then
        internal_timeout=10
    fi
else
    internal_timeout=10
fi

if [ -n "${external_timeout}" ]
then
    if ! test ${external_timeout} -gt 0 > /dev/null 2>&1
    then
        echo "Illegal Image Boards API timeout" \
            "\nSee '${0} -h'"
        exit 1
    fi

    if [ ${external_timeout} -gt 10 ]
    then
        external_timeout=10
    fi
else
    external_timeout=5
fi

if [ -n "${head_timeout}" ]
then
    if ! test ${head_timeout} -gt 0 > /dev/null 2>&1
    then
        echo "Illegal head request timeout" \
            "\nSee '${0} -h'"
        exit 1
    fi

    if [ ${head_timeout} -gt 10 ]
    then
        head_timeout=10
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
    echo "Unrecognized action ${1}" \
        "\nSee '${0} -h'"
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

rm -fr "${cache}"
mkdir -p "${cache}"
mkdir -p "${config}"

for file in aliases blacklist whitelist help
do
    if ! [ -f "${files}/${file}.txt" ]
    then
        cat "${files}/${file}.txt.default" > "${files}/${file}.txt"
    fi
done

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

    if [ "${update_id}" = "null" ]
    then
        continue
    fi

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
done
