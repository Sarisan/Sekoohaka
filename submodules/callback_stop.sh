# Copyright (C) 2024-2025 Maria Lisina
# Copyright (C) 2024-2025 Danil Lisin
# SPDX-License-Identifier: Apache-2.0

if mkdir "${user_config}_stop.lock"
then
    notification_text="Click again to confirm data removal"
    return 0
fi

locks="auth short"

for lock in ${locks}
do
    until mkdir "${user_config}_${lock}.lock"
    do
        sleep 1
    done
done

if rm -fr "${user_config}"
then
    notification_text="Removed all your data"
else
    notification_text="Something went wrong, try again later"
fi

for lock in ${locks}
do
    rm -fr "${user_config}_${lock}.lock"
done

rm -fr "${user_config}_stop.lock"
