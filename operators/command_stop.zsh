# Copyright (C) 2024-2026 Maria Lisina
# Copyright (C) 2024-2026 Danil Lisin
# SPDX-License-Identifier: Apache-2.0

if [[ "${chat_id}" != "${target_user}" ]]
then
    output_text="For security reasons you can execute this command only in direct messages"
    return
fi

until mkdir "${user_config}.lock"
do
    sleep 1
done

source "${units}/stop.zsh"

rmdir "${user_config}.lock"
