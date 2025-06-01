# Copyright (C) 2024-2025 Maria Lisina
# Copyright (C) 2024-2025 Danil Lisin
# SPDX-License-Identifier: Apache-2.0

if [[ -z "${ib_login}" ]]
then
    if [[ -f "${user_config}/${ib_config}/${ib_login_file}" ]]
    then
        ib_login="$(< "${user_config}/${ib_config}/${ib_login_file}")"
    else
        output_text="You must specify the ${ib_login_word} and the ${ib_key_word}"
        return 0
    fi
fi

if [[ -z "${ib_key}" ]]
then
    if [[ -f "${user_config}/${ib_config}/${ib_key_file}" ]]
    then
        ib_key="$(< "${user_config}/${ib_config}/${ib_key_file}")"
    else
        output_text="You must specify the ${ib_key_word}"
        return 0
    fi
fi

if ! mkdir -p "${user_config}/${ib_config}"
then
    output_text="Failed to create user config"
    return 0
fi

case "${ib_board}" in
    (d)
        ib_auth_file="${cache}/${update_id}_profile.json"
        dump+=(${ib_auth_file##*/})

        if ! curl --max-time ${external_timeout} \
            --output "${ib_auth_file}" \
            --proxy "${external_proxy}" \
            --request GET \
            --silent \
            --user "${ib_login}:${ib_key}" \
            --user-agent "${useragent}" \
            "${ib_auth}/profile.json"
        then
            output_text="Failed to process request"
            log_text="ib_auth (${update_id}): ${output_text}"

            . "${units}/log.zsh"
            . "${units}/dump.zsh"

            return 0
        fi

        if ! jq -e '.' "${ib_auth_file}" > /dev/null
        then
            output_text="An unknown error occurred"
            log_text="ib_auth (${update_id}): ${output_text}"

            . "${units}/log.zsh"
            . "${units}/dump.zsh"

            return 0
        fi

        if [[ "$(jq -r '.success' "${ib_auth_file}")" = "false" ]]
        then
            output_text="Error: <code>$(jq -r '.message' "${ib_auth_file}" | htmlescape)</code>"
            log_text="ib_auth (${update_id}): Error: $(jq -r '.message' "${ib_auth_file}")"

            . "${units}/log.zsh"
            . "${units}/dump.zsh"

            return 0
        fi

        if [[ "$(jq -r '.name' "${ib_auth_file}")" != "${ib_login}" ]]
        then
            output_text="An unexpected error occurred"
            log_text="ib_auth (${update_id}): ${output_text}"

            . "${units}/log.zsh"
            . "${units}/dump.zsh"

            return 0
        fi

        printf "%s" "${ib_login}:${ib_key}" | base64 > "${user_config}/${ib_config}/token"
    ;;
    (g)
        printf '%s="%s"\n%s="%s"\n' \
            "ib_dfield5" "user_id=${ib_login}" \
            "ib_dfield6" "api_key=${ib_key}" > "${user_config}/${ib_config}/legacy"
    ;;
    (i)
        ib_cookies="${user_config}/${ib_config}/cookies"
        ib_auth_file="${cache}/${update_id}_login.html"
        dump+=(${ib_auth_file##*/})

        if ! curl --cookie-jar "${ib_cookies}" \
            --max-time ${external_timeout} \
            --output "${ib_auth_file}" \
            --proxy "${external_proxy}" \
            --request GET \
            --silent \
            --user-agent "${useragent}" \
            "${ib_auth}/users/login"
        then
            output_text="Failed to process request"
            log_text="ib_auth (${update_id}): ${output_text}"

            . "${units}/log.zsh"
            . "${units}/dump.zsh"

            return 0
        fi

        ib_action="$(xq -a "action" -q "form" "${ib_auth_file}")"
        ib_token="$(xq -a "value" -q "form>input[name=authenticity_token]" "${ib_auth_file}")"

        if [[ -z "${ib_action}" || -z "${ib_token}" ]]
        then
            output_text="Failed to process request"
            log_text="ib_auth (${update_id}): ${output_text}"

            . "${units}/log.zsh"
            . "${units}/dump.zsh"

            return 0
        fi

        ib_auth_file="${cache}/${update_id}_authenticate.html"
        dump+=(${ib_auth_file##*/})

        if ! curl --cookie "${ib_cookies}" \
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
            --silent \
            --user-agent "${useragent}" \
            "${ib_auth}${ib_action}"
        then
            output_text="Failed to process request"
            log_text="ib_auth (${update_id}): ${output_text}"

            . "${units}/log.zsh"
            . "${units}/dump.zsh"

            return 0
        fi

        if [[ -s "${ib_auth_file}" ]]
        then
            output_text="Failed to process request"
            log_text="ib_auth (${update_id}): ${output_text}"

            . "${units}/log.zsh"
            . "${units}/dump.zsh"

            return 0
        fi

        ib_auth_file="${cache}/${update_id}_home.html"
        dump+=(${ib_auth_file##*/})

        if ! curl --cookie "${ib_cookies}" \
            --max-time ${external_timeout} \
            --output "${ib_auth_file}" \
            --proxy "${external_proxy}" \
            --request GET \
            --silent \
            --user-agent "${useragent}" \
            "${ib_auth}/users/home"
        then
            output_text="Failed to process request"
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
            output_text="Failed to process request"
            log_text="ib_auth (${update_id}): ${output_text}"

            . "${units}/log.zsh"
            . "${units}/dump.zsh"

            return 0
        fi

        strftime %s > "${user_config}/${ib_config}/timestamp"
    ;;
    (s)
        ib_login_data="$(jq --null-input --compact-output \
            --arg login "${ib_login}" \
            --arg password "${ib_key}" \
            '{"login": $login, "password": $password}')"

        ib_auth_file="${cache}/${update_id}_token.json"
        dump+=(${ib_auth_file##*/})

        if ! curl --data "${ib_login_data}" \
            --header "Content-Type: application/json" \
            --max-time ${external_timeout} \
            --output "${ib_auth_file}" \
            --proxy "${external_proxy}" \
            --request POST \
            --silent \
            --user-agent "${useragent}" \
            "${ib_auth}/auth/token"
        then
            output_text="Failed to process request"
            log_text="ib_auth (${update_id}): ${output_text}"

            . "${units}/log.zsh"
            . "${units}/dump.zsh"

            return 0
        fi

        if ! jq -e '.' "${ib_auth_file}" > /dev/null
        then
            output_text="An unknown error occurred"
            log_text="ib_auth (${update_id}): ${output_text}"

            . "${units}/log.zsh"
            . "${units}/dump.zsh"

            return 0
        fi

        if [[ "$(jq -r '.success' "${ib_auth_file}")" != "true" ]]
        then
            output_text="Error: <code>$(jq -r '.error' "${ib_auth_file}" | htmlescape)</code>"
            log_text="ib_auth (${update_id}): Error: $(jq -r '.error' "${ib_auth_file}")"

            . "${units}/log.zsh"
            . "${units}/dump.zsh"

            return 0
        fi

        jq -r '.access_token' "${ib_auth_file}" > "${user_config}/${ib_config}/token"
        strftime %s > "${user_config}/${ib_config}/timestamp"
    ;;
    (k|y)
        ib_auth_file="${cache}/${update_id}_user.json"
        dump+=(${ib_auth_file##*/})

        if ! curl --data-urlencode "username=${ib_login}" \
            --data-urlencode "api_key=${ib_key}" \
            --get \
            --max-time ${external_timeout} \
            --output "${ib_auth_file}" \
            --proxy "${external_proxy}" \
            --silent \
            --user-agent "${useragent}" \
            "${ib_auth}/user.json"
        then
            output_text="Failed to process request"
            log_text="ib_auth (${update_id}): ${output_text}"

            . "${units}/log.zsh"
            . "${units}/dump.zsh"

            return 0
        fi

        if ! jq -e '.' "${ib_auth_file}" > /dev/null
        then
            output_text="Invalid username or API key"
            log_text="ib_auth (${update_id}): ${output_text}"

            . "${units}/log.zsh"
            . "${units}/dump.zsh"

            return 0
        fi

        printf '%s="%s"\n%s="%s"\n' \
            "ib_dfield5" "username=${ib_login}" \
            "ib_dfield6" "api_key=${ib_key}" > "${user_config}/${ib_config}/legacy"
    ;;
esac

printf "%s\n" "${ib_login}" > "${user_config}/${ib_config}/${ib_login_file}"
printf "%s\n" "${ib_key}" > "${user_config}/${ib_config}/${ib_key_file}"
