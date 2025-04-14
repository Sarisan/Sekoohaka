# Copyright (C) 2024-2025 Maria Lisina
# Copyright (C) 2024-2025 Danil Lisin
# SPDX-License-Identifier: Apache-2.0

if [ "${api_address}" != "${local_address}" ] && [ "${api_address}" != "${external_address}" ]
then
    output_text="This command is not available, please contact bot deployer"
    return 0
fi

until mkdir "${user_config}_saucenao.lock"
do
    sleep 1
done

. "${units}/sn_auth.sh"

if [ -n "${output_text}" ]
then
    rm -fr "${user_config}_saucenao.lock"
    return 0
fi

. "${units}/sn_get.sh"

if [ -n "${output_text}" ]
then
    rm -fr "${user_config}_saucenao.lock"
    return 0
fi

. "${units}/sn_search.sh"

if [ -n "${output_text}" ]
then
    rm -fr "${user_config}_saucenao.lock"
    return 0
fi

. "${units}/sn_result.sh"
rm -fr "${user_config}_saucenao.lock"
