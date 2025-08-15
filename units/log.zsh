# Copyright (C) 2024-2025 Maria Lisina
# Copyright (C) 2024-2025 Danil Lisin
# SPDX-License-Identifier: Apache-2.0

if [[ -n "${no_logs}" ]] && ! grep -q -e "^Error:" -e "^Warning:" <<< "${log_text}"
then
    return 0
fi

printf "[%s] %s\n" "$(strftime "%Y-%m-%d %X")" "${log_text}"
