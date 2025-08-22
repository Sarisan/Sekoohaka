# Copyright (C) 2024-2025 Maria Lisina
# Copyright (C) 2024-2025 Danil Lisin
# SPDX-License-Identifier: Apache-2.0

if [[ "${chat_id}" != "${target_user}" ]]
then
    output_text="For security reasons you can execute this command only in the bot chat"
    return 0
fi

until mkdir "${user_config}_data.lock"
do
    sleep 1
done

for lock in ${user_locks[@]}
do
    until mkdir "${user_config}_${lock}.lock"
    do
        sleep 1
    done
done

. "${units}/export.zsh"

for lock in ${user_locks[@]}
do
    rmdir "${user_config}_${lock}.lock"
done

rmdir "${user_config}_data.lock"

if [[ -z "${output_text}" ]]
then
    exit 0
fi
