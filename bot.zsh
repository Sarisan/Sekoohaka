#!/usr/bin/env zsh
#
# Copyright (C) 2024-2025 Maria Lisina
# Copyright (C) 2024-2025 Danil Lisin
# SPDX-License-Identifier: Apache-2.0

if [[ "${__bot_env}" != "0" ]]
then
    trap 'wait && exit 0' INT TERM
    env -i PATH="${PATH}" __bot_env=0 "${0}" ${@}
    exit ${?}
fi

exec 2> /dev/null

set -e
umask 77

version="2025.1201.0-release"
useragent="Sekoohaka/${version} Telegram Bot"

local_address="127.0.0.1:8081"
default_address="https://api.telegram.org"

dir="${0%/*}"
auth="${dir}/auth"
cache="${dir}/cache/${$}"
config="${dir}/config"
files="${dir}/files"
mods="${dir}/modules"
submods="${dir}/submodules"
units="${dir}/units"
users="${dir}/users"
offset=-1

data_table=(
    safebooru "Safebooru"
    danbooru "Danbooru"
    gelbooru "Gelbooru"
    idolcomplex "Idol Complex"
    konachan "Konachan.com"
    sankakuchannel "Sankaku Channel"
    yandere "yande.re"
    saucenao "SauceNAO"
    shorts "Shortcuts"
)

user_locks=(
    data
    auth
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
    sha1sum
    sleep
    tar
    tr
)

if [[ -n "${1}" ]]
then
    while getopts ha:olg:r:m:t:s:cqi:e:d:f:n:x:k: opts
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
                no_clear=0
            ;;
            (q)
                no_logs=0
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
            (k)
                sn_key="${OPTARG}"
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
        "\n  -c\t\tDo not clear cache automatically" \
        "\n  -q\t\tDo not print logs" \
        "\n  -i <secs>\tTelegram Bot API connetion timeout, max: 5, default: 5 secs" \
        "\n  -e <secs>\tImage Boards API connetion timeout, max: 5, default: 5 secs" \
        "\n  -d <secs>\tHead request connetion timeout, max: 5, default: 2 secs" \
        "\n  -f <secs>\tConnrefused timeout, max: 2, default: none" \
        "\n  -n <addr>\tProxy server for Telegram Bot API" \
        "\n  -x <addr>\tProxy server for Image Boards/SauceNAO API" \
        "\n  -k <key>\tSauceNAO API key for public use" \
        "\n\nCache modes:" \
        "\n  none\t\tNo cache reuse" \
        "\n  normal\tReuse inline results and posts cache" \
        "\n  advanced\tExtract posts cache from inline results" \
        "\n\nSupported Image Boards:" \
        "\n  Safebooru\t\t(https://safebooru.donmai.us/)" \
        "\n  Danbooru\t\t(https://danbooru.donmai.us/)" \
        "\n  Gelbooru\t\t(https://gelbooru.com/)" \
        "\n  Idol Complex\t\t(https://www.idolcomplex.com/)" \
        "\n  Konachan.com\t\t(https://konachan.com/)" \
        "\n  Sankaku Channel\t(https://www.sankakucomplex.com/)" \
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
        "\nUpdate your Z Shell or get a version with all required modules"
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
        "\nUpdate your BusyBox or get a version with all required functions"
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

if [[ -z "${api_token}" ]]
then
    echo "No Telegram Bot API Token specified"
    exit 1
fi

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

if ! input_data="$(
    curl --connect-timeout ${connrefused_timeout} \
        --get \
        --max-time 10 \
        --proxy "${internal_proxy}" \
        --retry 1 \
        --retry-connrefused \
        --retry-max-time $((10 - connrefused_timeout)) \
        --silent \
        --user-agent "${useragent}" \
        "${api_address}/bot${api_token}/getMe"
)"
then
    log_text="getMe: Failed to access Telegram Bot API"
    . "${units}/log.zsh"

    exit 1
fi

if ! jq -e '.' <<< "${input_data}" > /dev/null
then
    log_text="getMe: An unknown error occurred"
    . "${units}/log.zsh"

    exit 1
fi

if [[ "$(jq -r '.ok' <<< "${input_data}")" != "true" ]]
then
    error_description="$(jq -r '.description' <<< "${input_data}")"

    if [[ "${error_description}" != "null" ]]
    then
        log_text="getMe: ${error_description}"
    else
        log_text="getMe: An unknown error occurred"
    fi

    . "${units}/log.zsh"
    exit 1
fi

username="$(jq -r '.result.username' <<< "${input_data}")"

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

help_content="$(sed "s/{version_placeholder}/${version}/" "${files}/help.txt")"

if [[ ${#help_content} -lt 1 ]]
then
    log_text="Error: File help.txt must be at least 1 character long"
    . "${units}/log.zsh"

    exit 1
fi

log_text="Running donate command check..."
. "${units}/log.zsh"

donate_content="$(< "${files}/donate.txt")"

if [[ ${#donate_content} -lt 1 ]]
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
    if ! input_data="$(
        curl --connect-timeout ${connrefused_timeout} \
            --data "user_id=${api_token%:*}" \
            --get \
            --max-time ${internal_timeout} \
            --proxy "${internal_proxy}" \
            --retry 1 \
            --retry-connrefused \
            --retry-max-time $((internal_timeout - connrefused_timeout)) \
            --silent \
            --user-agent "${useragent}" \
            "${api_address}/bot${api_token}/getUserProfilePhotos"
    )"
    then
        log_text="getUserProfilePhotos: Failed to access Telegram Bot API"
        . "${units}/log.zsh"

        exit 1
    fi

    if ! jq -e '.' <<< "${input_data}" > /dev/null
    then
        log_text="getUserProfilePhotos: An unknown error occurred"
        . "${units}/log.zsh"

        exit 1
    fi

    if [[ "$(jq -r '.ok' <<< "${input_data}")" != "true" ]]
    then
        error_description="$(jq -r '.description' <<< "${input_data}")"

        if [[ "${error_description}" != "null" ]]
        then
            log_text="getUserProfilePhotos: ${error_description}"
        else
            log_text="getUserProfilePhotos: An unknown error occurred"
        fi

        . "${units}/log.zsh"
        exit 1
    fi

    profilephoto="$(jq -r '.result.photos[].[0].file_id' <<< "${input_data}")"

    if [[ -z "${profilephoto}" || "${profilephoto}" == "null" ]]
    then
        log_text="Error: Bot must have profile photo to run source command check"
        . "${units}/log.zsh"

        exit 1
    fi

    if ! input_data="$(
        curl --connect-timeout ${connrefused_timeout} \
            --data-urlencode "file_id=${profilephoto}" \
            --get \
            --max-time ${internal_timeout} \
            --proxy "${internal_proxy}" \
            --retry 1 \
            --retry-connrefused \
            --retry-max-time $((internal_timeout - connrefused_timeout)) \
            --silent \
            --user-agent "${useragent}" \
            "${api_address}/bot${api_token}/getFile"
    )"
    then
        log_text="getFile: Failed to access Telegram Bot API"
        . "${units}/log.zsh"

        exit 1
    fi

    if ! jq -e '.' <<< "${input_data}" > /dev/null
    then
        log_text="getFile: An unknown error occurred"
        . "${units}/log.zsh"

        exit 1
    fi

    if [[ "$(jq -r '.ok' <<< "${input_data}")" != "true" ]]
    then
        error_description="$(jq -r '.description' <<< "${input_data}")"

        if [[ "${error_description}" != "null" ]]
        then
            log_text="getFile: ${error_description}"
        else
            log_text="getFile: An unknown error occurred"
        fi

        . "${units}/log.zsh"
        exit 1
    fi

    profilephoto_path="$(jq -r '.result.file_path' <<< "${input_data}")"

    if [[ "${api_address}" == "${local_address}" ]]
    then
        if ! ls "${profilephoto_path}" > /dev/null
        then
            nocommand_source=0

            log_text="Error: Cannot access Telegram Bot API working directory, source command is disabled"
            . "${units}/log.zsh"
        fi
    else
        if ! input_data="$(
            curl --connect-timeout ${connrefused_timeout} \
                --max-time ${internal_timeout} \
                --proxy "${internal_proxy}" \
                --retry 1 \
                --retry-connrefused \
                --retry-max-time $((external_timeout - connrefused_timeout)) \
                --silent \
                --user-agent "${useragent}" \
                "${api_address}/file/bot${api_token}/${profilephoto_path}"
        )"
        then
            nocommand_source=0

            log_text="Error: Failed to download file, source command is disabled"
            . "${units}/log.zsh"
        fi

        if [[ "$(jq -r '.ok' <<< "${input_data}")" == "false" ]]
        then
            nocommand_source=0
            error_description="$(jq -r '.description' <<< "${input_data}")"

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

if [[ -z "${nocommand_source}" && -n "${sn_key}" ]]
then
    if ! input_data="$(
        curl --connect-timeout ${connrefused_timeout} \
            --data-urlencode "output_type=2" \
            --data-urlencode "api_key=${sn_key}" \
            --get \
            --max-time ${external_timeout} \
            --proxy "${external_proxy}" \
            --retry 1 \
            --retry-connrefused \
            --retry-max-time $((external_timeout - connrefused_timeout)) \
            --silent \
            --user-agent "${useragent}" \
            "https://saucenao.com/search.php"
    )"
    then
        log_text="SauceNAO: Failed to access SauceNAO API"
        . "${units}/log.zsh"

        exit 1
    fi

    if ! jq -e '.' <<< "${input_data}" > /dev/null
    then
        log_text="SauceNAO: An unknown error occurred"
        . "${units}/log.zsh"

        exit 1
    fi

    sn_status="$(jq -r '.header.status' <<< "${input_data}")"

    case "${sn_status}" in
        (-3)
        ;;
        (-2)
            log_text="SauceNAO: Rate limit exceeded, try again later"
            . "${units}/log.zsh"

            exit 1
        ;;
        (-1)
            log_text="SauceNAO: Invalid API key"
            . "${units}/log.zsh"

            exit 1
        ;;
        (*)
            log_text="SauceNAO: An unknown error occurred"
            . "${units}/log.zsh"

            exit 1
        ;;
    esac
fi

if [[ -n "${nocommand_donate}" ]]
then
    help_content="$(sed -e '/^<code>donate.*$/d' -e '/^\/donate.*$/d' <<< "${help_content}")"
fi

if [[ -n "${nocommand_source}" ]]
then
    help_content="$(sed -e '/^\[snkey\].*$/d' -e '/^\/source.*$/d' <<< "${help_content}")"
fi

strftime %s > "${cache}.timer"

log_text="Startup succeeded"
. "${units}/log.zsh"

while trap 'wait && exit 0' INT TERM
do
    . "${mods}/timer.zsh" &

    if ! input_data="$(
        curl --connect-timeout ${connrefused_timeout} \
            --data "offset=${offset}" \
            --data "limit=1" \
            --get \
            --max-time ${internal_timeout} \
            --proxy "${internal_proxy}" \
            --retry 1 \
            --retry-connrefused \
            --retry-max-time $((internal_timeout - connrefused_timeout)) \
            --silent \
            --user-agent "${useragent}" \
            "${api_address}/bot${api_token}/getUpdates"
    )"
    then
        log_text="getUpdates: Failed to access Telegram Bot API, sleeping for ${sleep_time} seconds"
        . "${units}/log.zsh"

        sleep ${sleep_time}
        continue
    fi

    if ! jq -e '.' <<< "${input_data}" > /dev/null
    then
        log_text="getUpdates: An unknown error occurred, sleeping for ${sleep_time} seconds"
        . "${units}/log.zsh"

        sleep ${sleep_time}
        continue
    fi

    if [[ "$(jq -r '.ok' <<< "${input_data}")" != "true" ]]
    then
        error_description="$(jq -r '.description' <<< "${input_data}")"

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

    update_id="$(jq -r '.result.[0].update_id' <<< "${input_data}")"

    if [[ "${update_id}" == "null" ]]
    then
        continue
    fi

    if ! update="$(jq -c '.result.[0]' <<< "${input_data}")"
    then
        log_text="Failed to write update data"
        . "${units}/log.zsh"

        continue
    fi

    for module in callback commands inline source
    do
        . "${mods}/${module}.zsh" &
    done

    offset=$((update_id + 1))
done
