# Copyright (C) 2024-2025 Maria Lisina
# Copyright (C) 2024-2025 Danil Lisin
# SPDX-License-Identifier: Apache-2.0

until mkdir "${user_config}_short.lock"
do
    sleep 1
done

shorts_config="${user_config}/shorts"

if [[ -d "${shorts_config}" ]]
then
    shorts=($(ls -x "${shorts_config}"))
fi

if [[ ${#shorts} -gt 0 ]]
then
    command="shorts"
else
    command="help"
fi

rmdir "${user_config}_short.lock"
