# Copyright (C) 2024-2025 Maria Lisina
# Copyright (C) 2024-2025 Danil Lisin
# SPDX-License-Identifier: Apache-2.0

until mkdir "${config}/${user_id}_short.lock" > /dev/null 2>&1
do
    sleep 1
done

short_config="${config}/${user_id}/short"

if [ -d "${short_config}" ]
then
    shorts="$(ls -x "${short_config}")"
fi

set -- ${shorts}

if [ ${#} -gt 0 ]
then
    command="shorts"
else
    command="help"
fi

shift ${#}

rm -fr "${config}/${user_id}_short.lock"
