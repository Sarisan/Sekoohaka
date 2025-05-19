# Copyright (C) 2024-2025 Maria Lisina
# Copyright (C) 2024-2025 Danil Lisin
# SPDX-License-Identifier: Apache-2.0

until mkdir "${user_config}_short.lock"
do
    sleep 1
done

short_config="${user_config}/short"

if [[ -d "${short_config}" ]]
then
    shorts=($(ls -x "${short_config}"))
fi

if [[ ${#shorts} -gt 0 ]]
then
    command="shorts"
else
    command="help"
fi

rm -fr "${user_config}_short.lock"
