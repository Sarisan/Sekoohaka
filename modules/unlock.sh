# Copyright (C) 2024 Maria Lisina
# Copyright (C) 2024 Danil Lisin
# SPDX-License-Identifier: Apache-2.0

find "${cache}" "${config}" -follow -name "*.lock" -type d -mmin +1 -exec rm -fr {} +
