# Copyright (C) 2024-2025 Maria Lisina
# Copyright (C) 2024-2025 Danil Lisin
# SPDX-License-Identifier: Apache-2.0

ib_cookies="${cookies_file}"
ib_auth_file="${cache}/${update_id}_login.html"
dump+=(${ib_auth_file##*/})

if ! curl --connect-timeout ${connrefused_timeout} \
    --cookie-jar "${ib_cookies}" \
    --max-time ${external_timeout} \
    --output "${ib_auth_file}" \
    --proxy "${external_proxy}" \
    --request GET \
    --retry 1 \
    --retry-connrefused \
    --retry-max-time $((external_timeout - connrefused_timeout)) \
    --silent \
    --user-agent "${useragent}" \
    "${ib_auth}/users/login"
then
    output_text="Failed to access ${ib_name} API"
    log_text="ib_auth (${update_id}): ${output_text}"

    . "${units}/log.zsh"
    . "${units}/dump.zsh"

    return 0
fi

ib_action="$(xq -a "action" -q "form" "${ib_auth_file}")"
ib_token="$(xq -a "value" -q "form>input[name=authenticity_token]" "${ib_auth_file}")"

if [[ -z "${ib_action}" || -z "${ib_token}" ]]
then
    output_text="Failed to get authorization data"
    log_text="ib_auth (${update_id}): ${output_text}"

    . "${units}/log.zsh"
    . "${units}/dump.zsh"

    return 0
fi

ib_auth_file="${cache}/${update_id}_authenticate.html"
dump+=(${ib_auth_file##*/})

if ! curl --connect-timeout ${connrefused_timeout} \
    --cookie "${ib_cookies}" \
    --cookie-jar "${ib_cookies}" \
    --data-urlencode "authenticity_token=${ib_token}" \
    --data-urlencode "user[name]=${ib_login}" \
    --data-urlencode "user[password]=${ib_key}" \
    --data-urlencode "commit=Login" \
    --header "Referer: ${ib_auth}/users/login" \
    --max-time ${external_timeout} \
    --output "${ib_auth_file}" \
    --proxy "${external_proxy}" \
    --request POST \
    --retry 1 \
    --retry-connrefused \
    --retry-max-time $((external_timeout - connrefused_timeout)) \
    --silent \
    --user-agent "${useragent}" \
    "${ib_auth}${ib_action}"
then
    output_text="Failed to access ${ib_name} API"
    log_text="ib_auth (${update_id}): ${output_text}"

    . "${units}/log.zsh"
    . "${units}/dump.zsh"

    return 0
fi

if [[ -s "${ib_auth_file}" ]]
then
    output_text="An unknown error occurred"
    log_text="ib_auth (${update_id}): ${output_text}"

    . "${units}/log.zsh"
    . "${units}/dump.zsh"

    return 0
fi

ib_auth_file="${cache}/${update_id}_home.html"
dump+=(${ib_auth_file##*/})

if ! curl --connect-timeout ${connrefused_timeout} \
    --cookie "${ib_cookies}" \
    --max-time ${external_timeout} \
    --output "${ib_auth_file}" \
    --proxy "${external_proxy}" \
    --request GET \
    --retry 1 \
    --retry-connrefused \
    --retry-max-time $((external_timeout - connrefused_timeout)) \
    --silent \
    --user-agent "${useragent}" \
    "${ib_auth}/users/home"
then
    output_text="Failed to access ${ib_name} API"
    log_text="ib_auth (${update_id}): ${output_text}"

    . "${units}/log.zsh"
    . "${units}/dump.zsh"

    return 0
fi

ib_notice="$(xq -q "div[id=notice]" "${ib_auth_file}")"

if [[ -n "${ib_notice}" && "${ib_notice}" != "You are now logged in" ]]
then
    output_text="$(printf "%s" "${ib_notice}" | htmlescape)"
    log_text="ib_auth (${update_id}): ${ib_notice}"

    . "${units}/log.zsh"
    . "${units}/dump.zsh"

    return 0
fi

if [[ -z "${ib_notice}" ]]
then
    output_text="Failed to verify user authorization"
    log_text="ib_auth (${update_id}): ${output_text}"

    . "${units}/log.zsh"
    . "${units}/dump.zsh"

    return 0
fi

strftime %s > "${timestamp_file}"
