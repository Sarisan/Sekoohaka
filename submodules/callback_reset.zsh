# Copyright (C) 2024-2025 Maria Lisina
# Copyright (C) 2024-2025 Danil Lisin
# SPDX-License-Identifier: Apache-2.0

if mkdir "${user_config}_reset.lock"
then
    notification_text="Click again to confirm shortcuts removal"
    return 0
fi

until mkdir "${user_config}_short.lock"
do
    sleep 1
done

if rm -fr "${user_config}/short"
then
    notification_text="Removed all shortcuts"
else
    notification_text="Something went wrong, try again later"
fi

rm -fr "${user_config}_short.lock"
rm -fr "${user_config}_reset.lock"
