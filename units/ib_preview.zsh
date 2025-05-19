# Copyright (C) 2024-2025 Maria Lisina
# Copyright (C) 2024-2025 Danil Lisin
# SPDX-License-Identifier: Apache-2.0

if [[ "${ib_preview_url}" = "${ib_sample_url}" ]]
then
    ib_preview_url="${ib_error_url}"
    ib_width="${ib_error_width}"
    ib_height="${ib_error_height}"
fi
