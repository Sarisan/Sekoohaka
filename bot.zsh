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

if command -v git > /dev/null
then
    gitrev="$(git rev-parse --short HEAD)"
fi

version="4.0-${gitrev:-inadev}"
useragent="Sekoohaka/${version} Telegram Bot"

local_address="127.0.0.1:8081"
default_address="https://api.telegram.org"

dir="${0%/*}"
cache="${dir}/cache/${$}"
config="${dir}/config"
dumps="${dir}/dumps/${$}"
files="${dir}/files"
mods="${dir}/modules"
submods="${dir}/submodules"
units="${dir}/units"
offset=-1

if [[ -n "${1}" ]]
then
    while getopts ha:lg:r:m:t:s:cjqui:e:d:n:x: opts
    do
        case "${opts}" in
            (h)
                help=0
            ;;
            (a)
                api_address="${OPTARG}"
            ;;
            (l)
                api_address="${local_address}"
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
            (s)
                sleeping_time=${OPTARG}
            ;;
            (c)
                clear_cache=0
            ;;
            (j)
                threaded_hash=0
            ;;
            (q)
                no_logs=0
            ;;
            (u)
                collect_dumps=0
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

if [[ -n "${help}" ]]
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
        "\n  -s <secs>\tSleeping time, max: 100, default: 10 secs" \
        "\n  -c\t\tClear cache automatically" \
        "\n  -j\t\tUse threaded MD5 hash lookup" \
        "\n  -q\t\tDo not print logs" \
        "\n  -u\t\tCollect debug dumps" \
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
        "\n  Safebooru\t\t(https://safebooru.donmai.us/)" \
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

if [[ -n "${missing}" ]]
then
    echo "Missing dependencies:${missing}" \
        "\nFor more information follow: https://command-not-found.com/"
    exit 1
fi

for function in base64 cp cut find grep ls sed sort sha1sum sleep tr
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

for module in zsh/datetime zsh/files zsh/stat zsh/zutil
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

if [[ -z "${api_address}" ]]
then
    api_address="${default_address}"
fi

if [[ -n "${shorts_limit}" ]]
then
    if ! test ${shorts_limit} -gt 0
    then
        echo "Illegal shortcuts limit number" \
            "\nSee '${0} -h'"
        exit 1
    fi

    if [[ ${shorts_limit} -gt 10000 ]]
    then
        shorts_limit=10000
    fi
else
    shorts_limit=100
fi

if [[ -n "${inline_limit}" ]]
then
    if ! test ${inline_limit} -gt 0
    then
        echo "Illegal inline results limit number" \
            "\nSee '${0} -h'"
        exit 1
    fi

    if [[ ${inline_limit} -gt 50 ]]
    then
        inline_limit=50
    fi
else
    inline_limit=10
fi

if [[ -n "${caching_mode}" ]]
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

if [[ -n "${caching_time}" ]]
then
    if ! test ${caching_time} -gt 0
    then
        echo "Illegal caching time" \
            "\nSee '${0} -h'"
        exit 1
    fi

    if [[ ${caching_time} -gt 1000 ]]
    then
        caching_time=1000
    fi
else
    caching_time=300
fi

if [[ -n "${sleeping_time}" ]]
then
    if ! test ${sleeping_time} -gt 0
    then
        echo "Illegal sleeping time" \
            "\nSee '${0} -h'"
        exit 1
    fi

    if [[ ${sleeping_time} -gt 100 ]]
    then
        sleeping_time=100
    fi
else
    sleeping_time=10
fi

if [[ -n "${internal_timeout}" ]]
then
    if ! test ${internal_timeout} -gt 0
    then
        echo "Illegal Telegram Bot API timeout" \
            "\nSee '${0} -h'"
        exit 1
    fi

    if [[ ${internal_timeout} -gt 10 ]]
    then
        internal_timeout=10
    fi
else
    internal_timeout=10
fi

if [[ -n "${external_timeout}" ]]
then
    if ! test ${external_timeout} -gt 0
    then
        echo "Illegal Image Boards API timeout" \
            "\nSee '${0} -h'"
        exit 1
    fi

    if [[ ${external_timeout} -gt 10 ]]
    then
        external_timeout=10
    fi
else
    external_timeout=5
fi

if [[ -n "${head_timeout}" ]]
then
    if ! test ${head_timeout} -gt 0
    then
        echo "Illegal head request timeout" \
            "\nSee '${0} -h'"
        exit 1
    fi

    if [[ ${head_timeout} -gt 10 ]]
    then
        head_timeout=10
    fi
else
    head_timeout=2
fi

if [[ -n "${1}" ]]
then
    api_token="${1}"
    shift
fi

if [[ -n "${1}" ]]
then
    echo "Unrecognized action ${1}" \
        "\nSee '${0} -h'"
    exit 1
fi

until [[ -n "${api_token}" ]]
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

for file in aliases blacklist donate help whitelist
do
    if [[ -f "${files}/${file}.txt" ]]
    then
        file_ctime=$(stat +mtime "${files}/${file}.txt.default")
        file_mtime=$(stat +mtime "${files}/${file}.txt")

        if [[ ${file_ctime} -gt ${file_mtime} ]]
        then
            log_text="Warning: ${file}.txt is older than ${file}.txt.default"
            . "${units}/log.zsh"
        fi
    else
        < "${files}/${file}.txt.default" > "${files}/${file}.txt"
    fi
done

log_text="PID: ${$}"
. "${units}/log.zsh"

if ! curl --get \
    --max-time ${internal_timeout} \
    --output "${cache}/getMe.json" \
    --proxy "${internal_proxy}" \
    --show-error \
    --silent \
    --user-agent "${useragent}" \
    "${api_address}/bot${api_token}/getMe"
then
    log_text="getMe: Failed to access Telegram Bot API"
    . "${units}/log.zsh"

    exit 1
fi

if ! jq -e '.' "${cache}/getMe.json" > /dev/null
then
    log_text="getMe: An unknown error occurred"
    . "${units}/log.zsh"

    exit 1
fi

if [[ "$(jq -r '.ok' "${cache}/getMe.json")" != "true" ]]
then
    error_description="$(jq -r '.description' "${cache}/getMe.json")"

    if [[ "${error_description}" != "null" ]]
    then
        log_text="getMe: ${error_description}"
    else
        log_text="getMe: An unknown error occurred"
    fi

    . "${units}/log.zsh"
    exit 1
fi

username="$(jq -r '.result.username' "${cache}/getMe.json")"

if [[ "${username}" = "null" ]]
then
    log_text="Failed to get bot username"
    . "${units}/log.zsh"

    exit 1
fi

log_text="Bot: ${username}"
. "${units}/log.zsh"

while trap 'wait && exit 0' INT TERM
do
    if ! curl --data "offset=${offset}" \
        --get \
        --output "${cache}/getUpdates.json" \
        --proxy "${internal_proxy}" \
        --silent \
        --user-agent "${useragent}" \
        "${api_address}/bot${api_token}/getUpdates"
    then
        log_text="getUpdates: Failed to access Telegram Bot API, sleeping for ${sleeping_time} seconds"
        . "${units}/log.zsh"

        sleep ${sleeping_time}
        continue
    fi

    if ! jq -e '.' "${cache}/getUpdates.json" > /dev/null
    then
        log_text="getUpdates: An unknown error occurred, sleeping for ${sleeping_time} seconds"
        . "${units}/log.zsh"

        sleep ${sleeping_time}
        continue
    fi

    if [[ "$(jq -r '.ok' "${cache}/getUpdates.json")" != "true" ]]
    then
        error_description="$(jq -r '.description' "${cache}/getUpdates.json")"

        if [[ "${error_description}" != "null" ]]
        then
            log_text="getUpdates: ${error_description}, sleeping for ${sleeping_time} seconds"
        else
            log_text="getUpdates: An unknown error occurred, sleeping for ${sleeping_time} seconds"
        fi

        . "${units}/log.zsh"

        sleep ${sleeping_time}
        continue
    fi

    update_id="$(jq -r '.result.[0].update_id' "${cache}/getUpdates.json")"

    if [[ "${update_id}" = "null" ]]
    then
        continue
    fi

    update="${cache}/${update_id}.json"
    dump=(${update##*/})

    if ! jq -c '.result.[0]' "${cache}/getUpdates.json" > "${update}"
    then
        log_text="Failed to write update file ${update_id}.json"

        . "${units}/log.zsh"
        continue
    fi

    for module in "${mods}"/*
    do
        . "${module}" &
    done

    offset=$((update_id + 1))
done
