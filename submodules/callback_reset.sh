# Copyright (C) 2024 Maria Lisina
# Copyright (C) 2024 Danil Lisin
# SPDX-License-Identifier: Apache-2.0

if mkdir "${config}/${user_id}_reset.lock" > /dev/null 2>&1
then
    notification_text="Click again to confirm shortcuts removal"
    return 0
fi

until mkdir "${config}/${user_id}_short.lock" > /dev/null 2>&1
do
    sleep 1
done

if rm -fr "${config}/${user_id}/short"
then
    notification_text="Removed all shortcuts"
else
    notification_text="Something went wrong, try again later"
fi

rm -fr "${config}/${user_id}_short.lock"
rm -fr "${config}/${user_id}_reset.lock"
