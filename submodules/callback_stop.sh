# Copyright (C) 2024 Maria Lisina
# Copyright (C) 2024 Danil Lisin
# SPDX-License-Identifier: Apache-2.0

if mkdir "${config}/${user_id}_stop.lock" > /dev/null 2>&1
then
    notification_text="Click again to confirm data removal"
    return 0
fi

locks="auth short"

for lock in ${locks}
do
    until mkdir "${config}/${user_id}_${lock}.lock" > /dev/null 2>&1
    do
        sleep 1
    done
done

if rm -fr "${config}/${user_id}"
then
    notification_text="Removed all your data"
else
    notification_text="Something went wrong, try again later"
fi

for lock in ${locks}
do
    rm -fr "${config}/${user_id}_${lock}.lock"
done

rm -fr "${config}/${user_id}_stop.lock"
