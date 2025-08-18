#!/usr/bin/env zsh
#
# Copyright (C) 2024-2025 Maria Lisina
# Copyright (C) 2024-2025 Danil Lisin
# SPDX-License-Identifier: Apache-2.0

if [[ "${__bot_env}" != "0" ]]
then
    trap 'wait && exit 0' INT TERM
    env -i PATH="${PATH}" __bot_env=0 __bot_debug="${__bot_debug}" "${0}" ${@}
    exit ${?}
fi

if [[ "${__bot_debug}" != "0" ]]
then
    exec 2> /dev/null
fi

set -e
umask 77

version="2025.818.0-snapshot"
useragent="Sekoohaka/${version} Telegram Bot"

local_address="127.0.0.1:8081"
default_address="https://api.telegram.org"

dir="${0%/*}"
auth="${dir}/auth"
cache="${dir}/cache/${$}"
config="${dir}/config"
dumps="${dir}/dumps/${$}"
files="${dir}/files"
mods="${dir}/modules"
submods="${dir}/submodules"
units="${dir}/units"
users="${dir}/users"
offset=-1

board_table=(a d g i k s y)

user_locks=(
    auth
    export
    source
    shorts
)

zmods=(
    zsh/datetime
    zsh/files
    zsh/stat
    zsh/zutil
)

reqs=(
    busybox
    curl
    jq
    recode
)

busybox=(
    base64
    cut
    find
    grep
    ls
    sed
    sort
    sha1sum
    sleep
    tar
    tr
)

if [[ -n "${1}" ]]
then
    while getopts ha:olg:r:m:t:s:cjqui:e:d:f:n:x: opts
    do
        case "${opts}" in
            (h)
                help=0
            ;;
            (a)
                api_address="${OPTARG}"
            ;;
            (o)
                allow_source=0
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
                cache_mode=${OPTARG}
            ;;
            (t)
                cache_time=${OPTARG}
            ;;
            (s)
                sleep_time=${OPTARG}
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
            (f)
                connrefused_timeout=${OPTARG}
            ;;
            (n)
                internal_proxy="${OPTARG}"
            ;;
            (x)
                external_proxy="${OPTARG}"
            ;;
            (*)
                echo "Unrecognized options" \
                    "\nSee '${0} -h'"
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
        "\n  -o\t\tAllow SauceNAO with unknown Telegram Bot API instance" \
        "\n  -l\t\tUse local Telegram Bot API, address: 127.0.0.1:8081" \
        "\n  -r <num>\tInline results limit, max: 50, default: 10" \
        "\n  -g <num>\tShortcuts storage limit, max: 10000, default: 500" \
        "\n  -m <mode>\tCache mode, default: normal" \
        "\n  -t <secs>\tCache expiration time, max: 1000, default: 300 secs" \
        "\n  -s <secs>\tSleep duration time, max: 100, default: 10 secs" \
        "\n  -c\t\tClear cache automatically" \
        "\n  -j\t\tUse threaded MD5 hash lookup" \
        "\n  -q\t\tDo not print logs" \
        "\n  -u\t\tCollect debug dumps" \
        "\n  -i <secs>\tTelegram Bot API connetion timeout, max: 5, default: 5 secs" \
        "\n  -e <secs>\tImage Boards API connetion timeout, max: 5, default: 5 secs" \
        "\n  -d <secs>\tHead request connetion timeout, max: 5, default: 2 secs" \
        "\n  -f <secs>\tConnrefused timeout, max: 2, default: none" \
        "\n  -n <addr>\tProxy server for Telegram Bot API" \
        "\n  -x <addr>\tProxy server for Image Boards API/SauceNAO" \
        "\n\nCache modes:" \
        "\n  none\t\tNo cache reuse" \
        "\n  normal\tReuse inline results and posts cache" \
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

for zmod in ${zmods[@]}
do
    if ! zmodload ${zmod}
    then
        failed="${failed} ${zmod}"
    fi
done

if [[ -n "${failed}" ]]
then
    echo "Failed to load Z Shell modules:${failed}" \
        "\nUpdate your Z Shell or get a version with all the required modules"
    exit 1
fi

for req in ${reqs[@]}
do
    if ! command -v ${req} > /dev/null
    then
        missing="${missing} ${req}"
    fi
done

if [[ -n "${missing}" ]]
then
    echo "Missing dependencies:${missing}" \
        "\nFor more information follow: https://command-not-found.com/"
    exit 1
fi

for function in ${busybox[@]}
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
    shorts_limit=500
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

if [[ -n "${cache_mode}" ]]
then
    case "${cache_mode}" in
        (none | normal | advanced)
        ;;
        (*)
            echo "Unrecognized caching mode ${cache_mode}" \
                "\nSee '${0} -h'"
            exit 1
        ;;
    esac
else
    cache_mode=normal
fi

if [[ -n "${cache_time}" ]]
then
    if ! test ${cache_time} -gt 0
    then
        echo "Illegal caching time" \
            "\nSee '${0} -h'"
        exit 1
    fi

    if [[ ${cache_time} -gt 1000 ]]
    then
        cache_time=1000
    fi
else
    cache_time=300
fi

if [[ -n "${sleep_time}" ]]
then
    if ! test ${sleep_time} -gt 0
    then
        echo "Illegal sleeping time" \
            "\nSee '${0} -h'"
        exit 1
    fi

    if [[ ${sleep_time} -gt 100 ]]
    then
        sleep_time=100
    fi
else
    sleep_time=10
fi

if [[ -n "${internal_timeout}" ]]
then
    if ! test ${internal_timeout} -gt 0
    then
        echo "Illegal Telegram Bot API timeout" \
            "\nSee '${0} -h'"
        exit 1
    fi

    if [[ ${internal_timeout} -gt 5 ]]
    then
        internal_timeout=5
    fi
else
    internal_timeout=5
fi

if [[ -n "${external_timeout}" ]]
then
    if ! test ${external_timeout} -gt 0
    then
        echo "Illegal Image Boards API timeout" \
            "\nSee '${0} -h'"
        exit 1
    fi

    if [[ ${external_timeout} -gt 5 ]]
    then
        external_timeout=5
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

    if [[ ${head_timeout} -gt 5 ]]
    then
        head_timeout=5
    fi
else
    head_timeout=2
fi

if [[ -n "${connrefused_timeout}" ]]
then
    if ! test ${connrefused_timeout} -gt 0
    then
        echo "Illegal connrefused timeout" \
            "\nSee '${0} -h'"
        exit 1
    fi

    if [[ ${connrefused_timeout} -gt 2 ]]
    then
        connrefused_timeout=2
    fi
else
    connrefused_timeout=0
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

alias htmlescape="sed -e 's/</\&#60;/g' -e 's/>/\&#62;/g'"
alias urlencode="jq -Rr @uri"

log_text="PID: ${$}"
. "${units}/log.zsh"

log_text="CWD: $(pwd)"
. "${units}/log.zsh"

log_text="Creating directories..."
. "${units}/log.zsh"

rm -fr "${cache}"
mkdir -p "${cache}"
mkdir -p "${users}"

log_text="Retrieving bot information..."
. "${units}/log.zsh"

if ! curl --connect-timeout ${connrefused_timeout} \
    --get \
    --max-time 10 \
    --output "${cache}/getMe.json" \
    --proxy "${internal_proxy}" \
    --retry 1 \
    --retry-connrefused \
    --retry-max-time $((10 - connrefused_timeout)) \
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
log_text="Bot: ${username}"
. "${units}/log.zsh"

log_text="Running files age check..."
. "${units}/log.zsh"

for file in aliases blacklist donate help whitelist
do
    log_text="files/${file}.txt"
    . "${units}/log.zsh"

    if [[ -f "${files}/${file}.txt" ]]
    then
        if [[ "${files}/${file}.txt" -ot "${files}/${file}.txt.default" ]]
        then
            log_text="Warning: File ${file}.txt is older than ${file}.txt.default"
            . "${units}/log.zsh"
        fi
    else
        < "${files}/${file}.txt.default" > "${files}/${file}.txt"
    fi
done

log_text="Running files length check..."
. "${units}/log.zsh"

for file in donate help
do
    log_text="files/${file}.txt"
    . "${units}/log.zsh"

    file_content="$(< "${files}/${file}.txt")"

    if [[ ${#file_content} -gt 4096 ]]
    then
        log_text="Error: File ${file}.txt exceeds 4096 characters limit"
        . "${units}/log.zsh"
    fi
done

log_text="Running help command check..."
. "${units}/log.zsh"

file_content="$(< "${files}/help.txt")"

if [[ ${#file_content} -lt 1 ]]
then
    log_text="Error: File help.txt must be at least 1 character long"
    . "${units}/log.zsh"

    exit 1
fi

log_text="Running donate command check..."
. "${units}/log.zsh"

file_content="$(< "${files}/donate.txt")"

if [[ ${#file_content} -lt 1 ]]
then
    nocommand_donate=0
    log_text="Warning: File donate.txt is empty, donate command is disabled"

    . "${units}/log.zsh"
fi

log_text="Running source command check..."
. "${units}/log.zsh"

if [[ -z "${allow_source}" && "${api_address}" != "${local_address}" && "${api_address}" != "${default_address}" ]]
then
    nocommand_source=0
    log_text="Warning: You are running bot with unknown Telegram Bot API instance, source command is disabled"

    . "${units}/log.zsh"
else
    if ! curl --connect-timeout ${connrefused_timeout} \
        --data "user_id=${api_token%:*}" \
        --get \
        --max-time ${internal_timeout} \
        --output "${cache}/getUserProfilePhotos.json" \
        --proxy "${internal_proxy}" \
        --retry 1 \
        --retry-connrefused \
        --retry-max-time $((internal_timeout - connrefused_timeout)) \
        --silent \
        --user-agent "${useragent}" \
        "${api_address}/bot${api_token}/getUserProfilePhotos"
    then
        log_text="getUserProfilePhotos: Failed to access Telegram Bot API"
        . "${units}/log.zsh"

        exit 1
    fi

    if ! jq -e '.' "${cache}/getUserProfilePhotos.json" > /dev/null
    then
        log_text="getUserProfilePhotos: An unknown error occurred"
        . "${units}/log.zsh"

        exit 1
    fi

    if [[ "$(jq -r '.ok' "${cache}/getUserProfilePhotos.json")" != "true" ]]
    then
        error_description="$(jq -r '.description' "${cache}/getUserProfilePhotos.json")"

        if [[ "${error_description}" != "null" ]]
        then
            log_text="getUserProfilePhotos: ${error_description}"
        else
            log_text="getUserProfilePhotos: An unknown error occurred"
        fi

        . "${units}/log.zsh"
        exit 1
    fi

    profilephoto="$(jq -r '.result.photos[].[0].file_id' "${cache}/getUserProfilePhotos.json")"

    if [[ -z "${profilephoto}" || "${profilephoto}" == "null" ]]
    then
        log_text="Error: Bot must have profile photo to run source command check"

        . "${units}/log.zsh"
        exit 1
    fi

    if ! curl --connect-timeout ${connrefused_timeout} \
        --data-urlencode "file_id=${profilephoto}" \
        --get \
        --max-time ${internal_timeout} \
        --output "${cache}/getFile.json" \
        --proxy "${internal_proxy}" \
        --retry 1 \
        --retry-connrefused \
        --retry-max-time $((internal_timeout - connrefused_timeout)) \
        --silent \
        --user-agent "${useragent}" \
        "${api_address}/bot${api_token}/getFile"
    then
        log_text="getFile: Failed to access Telegram Bot API"
        . "${units}/log.zsh"

        exit 1
    fi

    if ! jq -e '.' "${cache}/getFile.json" > /dev/null
    then
        log_text="getFile: An unknown error occurred"

        . "${units}/log.zsh"
        exit 1
    fi

    if [[ "$(jq -r '.ok' "${cache}/getFile.json")" != "true" ]]
    then
        error_description="$(jq -r '.description' "${cache}/getFile.json")"

        if [[ "${error_description}" != "null" ]]
        then
            log_text="getFile: ${error_description}"
        else
            log_text="getFile: An unknown error occurred"
        fi

        . "${units}/log.zsh"
        exit 1
    fi

    profilephoto_path="$(jq -r '.result.file_path' "${cache}/getFile.json")"

    if [[ "${api_address}" == "${local_address}" ]]
    then
        if ! ls "${profilephoto_path}" > /dev/null
        then
            nocommand_source=0
            log_text="Error: Cannot access Telegram Bot API working directory, source command is disabled"

            . "${units}/log.zsh"
        fi
    else
        if ! curl --connect-timeout ${connrefused_timeout} \
            --max-time ${internal_timeout} \
            --output "${cache}/file.jpg" \
            --proxy "${internal_proxy}" \
            --retry 1 \
            --retry-connrefused \
            --retry-max-time $((external_timeout - connrefused_timeout)) \
            --silent \
            --user-agent "${useragent}" \
            "${api_address}/file/bot${api_token}/${profilephoto_path}"
        then
            nocommand_source=0
            log_text="Error: Failed to download file, source command is disabled"

            . "${units}/log.zsh"
        fi

        if [[ "$(jq -r '.ok' "${cache}/file.jpg")" == "false" ]]
        then
            nocommand_source=0
            error_description="$(jq -r '.description' "${cache}/file.jpg")"

            if [[ "${error_description}" != "null" ]]
            then
                log_text="Error: ${error_description}, source command is disabled"
            else
                log_text="Error: An unknown error occurred, source command is disabled"
            fi

            . "${units}/log.zsh"
        fi
    fi
fi

log_text="Loading lists..."
. "${units}/log.zsh"

log_text="files/aliases.txt"
. "${units}/log.zsh"

aliases_list="$(< "${files}/aliases.txt")"
aliases_length=${#aliases_list}

log_text="files/blacklist.txt"
. "${units}/log.zsh"

blacklist_list="$(< "${files}/blacklist.txt")"
blacklist_length=${#blacklist_list}

log_text="files/whitelist.txt"
. "${units}/log.zsh"

whitelist_list="$(< "${files}/whitelist.txt")"
whitelist_length=${#whitelist_list}

strftime %s > "${cache}.timer"

log_text="Startup succeeded"
. "${units}/log.zsh"

while trap 'wait && exit 0' INT TERM
do
    . "${mods}/timer.zsh" &

    if ! curl --connect-timeout ${connrefused_timeout} \
        --data "offset=${offset}" \
        --data "limit=1" \
        --get \
        --output "${cache}/getUpdates.json" \
        --proxy "${internal_proxy}" \
        --retry 1 \
        --retry-connrefused \
        --retry-max-time $((internal_timeout - connrefused_timeout)) \
        --silent \
        --user-agent "${useragent}" \
        "${api_address}/bot${api_token}/getUpdates"
    then
        log_text="getUpdates: Failed to access Telegram Bot API, sleeping for ${sleep_time} seconds"
        . "${units}/log.zsh"

        sleep ${sleep_time}
        continue
    fi

    if ! jq -e '.' "${cache}/getUpdates.json" > /dev/null
    then
        log_text="getUpdates: An unknown error occurred, sleeping for ${sleep_time} seconds"
        . "${units}/log.zsh"

        sleep ${sleep_time}
        continue
    fi

    if [[ "$(jq -r '.ok' "${cache}/getUpdates.json")" != "true" ]]
    then
        error_description="$(jq -r '.description' "${cache}/getUpdates.json")"

        if [[ "${error_description}" != "null" ]]
        then
            log_text="getUpdates: ${error_description}, sleeping for ${sleep_time} seconds"
        else
            log_text="getUpdates: An unknown error occurred, sleeping for ${sleep_time} seconds"
        fi

        . "${units}/log.zsh"

        sleep ${sleep_time}
        continue
    fi

    update_id="$(jq -r '.result.[0].update_id' "${cache}/getUpdates.json")"

    if [[ "${update_id}" == "null" ]]
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

    for module in callback commands inline source
    do
        . "${mods}/${module}.zsh" &
    done

    offset=$((update_id + 1))
done
