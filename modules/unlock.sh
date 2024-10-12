# Copyright (C) 2024 Maria Lisina
# Copyright (C) 2024 Danil Lisin
# SPDX-License-Identifier: Apache-2.0

if ! mkdir "${cache}.unlock" > /dev/null 2>&1
then
    exit 0
fi

find "${cache}" "${config}" -follow -name "*.lock" -type d -mmin +1 -exec rm -fr {} +

rm -fr "${cache}.unlock"
