# Copyright (C) 2024-2025 Maria Lisina
# Copyright (C) 2024-2025 Danil Lisin
# SPDX-License-Identifier: Apache-2.0

output_text="$(sed "s/{version}/${version}/" < "${files}/help.txt")"

if [[ -n "${nocommand_donate}" ]]
then
    output_text="$(sed -e '/^<code>donate.*$/d' -e '/^\/donate.*$/d' <<< "${output_text}")"
fi

if [[ -n "${nocommand_source}" ]]
then
    output_text="$(sed -e '/^\[snkey\].*$/d' -e '/^\/source.*$/d' <<< "${output_text}")"
fi
