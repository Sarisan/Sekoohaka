# Copyright (C) 2024-2026 Maria Lisina
# Copyright (C) 2024-2026 Danil Lisin
# SPDX-License-Identifier: Apache-2.0

until mkdir "${user_config}.lock"
do
    sleep 1
done

shorts_config="${user_config}/shorts"

if [[ -d "${shorts_config}" ]]
then
    shorts=($(ls -1 "${shorts_config}"))
fi

if [[ ${#shorts} -gt 0 ]]
then
    command="shorts"
else
    command="help"
fi

rmdir "${user_config}.lock"
