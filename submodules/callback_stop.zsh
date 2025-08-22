# Copyright (C) 2024-2025 Maria Lisina
# Copyright (C) 2024-2025 Danil Lisin
# SPDX-License-Identifier: Apache-2.0

if [[ -n "${1}" ]]
then
    data_name="${1}"
    shift
fi

while [[ -n "${data_name}" && ${#data_table} -ge 2 ]]
do
    if [[ "${data_name}" == "${data_table[2]}" ]]
    then
        break
    elif [[ "${data_table[2]}" == "${data_table[-1]}" ]]
    then
        notification_text="Could not find requested data"
        return 0
    fi

    shift 2 data_table
done

if mkdir "${user_config}_stop.lock"
then
    notification_text="Click again to confirm data removal"
    return 0
fi

for lock in ${user_locks[@]}
do
    until mkdir "${user_config}_${lock}.lock"
    do
        sleep 1
    done
done

if [[ -n "${data_name}" ]] && rm -fr "${user_config}/${data_table[2]}"
then
    if [[ "${data_table[2]}" == "shorts" ]]
    then
        notification_text="Successfully removed all your shortcuts"
    else
        notification_text="Successfully removed ${data_table[1]} data"
    fi
elif [[ -z "${data_name}" ]] && rm -fr "${user_config}"
then
    notification_text="Successfully removed all your data"
else
    notification_text="Something went wrong, try again later"
fi

for lock in ${user_locks[@]}
do
    rmdir "${user_config}_${lock}.lock"
done

rmdir "${user_config}_stop.lock"
