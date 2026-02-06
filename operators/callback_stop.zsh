# Copyright (C) 2024-2026 Maria Lisina
# Copyright (C) 2024-2026 Danil Lisin
# SPDX-License-Identifier: Apache-2.0

if [[ -n "${1}" ]]
then
    data_name="${1}"
    check_table=(${data_table[@]})
    shift
fi

while [[ ${#check_table} -ge 2 ]]
do
    if [[ "${data_name}" == "${check_table[1]}" ]]
    then
        break
    elif [[ "${check_table[1]}" == "${check_table[-2]}" ]]
    then
        notification_text="No requested data found"
        return
    fi

    shift 2 check_table
done

if mkdir "${user_config}_stop.lock"
then
    notification_text="Click again to confirm data removal"
    return
fi

for lock in ${user_locks[@]}
do
    until mkdir "${user_config}_${lock}.lock"
    do
        sleep 1
    done
done

if [[ -n "${data_name}" ]]
then
    if ! rm -fr "${user_config}/${check_table[1]}"
    then
        notification_text="Something went wrong, try again later"
    fi
else
    if ! rm -fr "${user_config}"
    then
        notification_text="Something went wrong, try again later"
    fi
fi

if [[ -d "${user_config}" ]]
then
    user_data=($(ls -1 "${user_config}"))

    if [[ ${#user_data} -eq 0 ]]
    then
        rmdir "${user_config}"
    fi
fi

source "${units}/stop.zsh"

for lock in ${user_locks[@]}
do
    rmdir "${user_config}_${lock}.lock"
done

rmdir "${user_config}_stop.lock"
