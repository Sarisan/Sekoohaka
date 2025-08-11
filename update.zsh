#!/usr/bin/env zsh
#
# Copyright (C) 2024-2025 Maria Lisina
# Copyright (C) 2024-2025 Danil Lisin
# SPDX-License-Identifier: Apache-2.0

for shorts in $(find users -type d -name shorts)
do
    for short in $(ls -1tr "${shorts}")
    do
        short_query="$(< "${shorts}/${short}")"
        mv -v "${shorts}/${short}" "${shorts}/$(sha1sum <<< "${short_query}" | cut -d ' ' -f 1)"
    done
done
