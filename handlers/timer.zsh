# Copyright (C) 2024-2026 Maria Lisina
# Copyright (C) 2024-2026 Danil Lisin
# SPDX-License-Identifier: Apache-2.0

if ! mkdir "${cache}.lock"
then
    exit 0
fi

timer_ctime=$(strftime %s)
timer_mtime=$(< "${cache}.timer")

if [[ $((timer_ctime - timer_mtime)) -lt 5 ]]
then
    rmdir "${cache}.lock"
    exit 0
fi

source "${agents}/timer_unlock.zsh"
source "${agents}/timer_uncache.zsh"

strftime %s > "${cache}.timer"
rmdir "${cache}.lock"
