# Copyright (C) 2024 Maria Lisina
# Copyright (C) 2024 Danil Lisin
# SPDX-License-Identifier: Apache-2.0

output_text="$(echo "<b>Sekoohaka Bot v${version}</b>" \
    "\n\n<b>Fields descriptions:</b>" \
    "\n[command] - Inline command" \
    "\n[b] - Image Board" \
    "\n[page] - Search page number" \
    "\n[options] - Search options" \
    "\n[name] - Search pool or tag name" \
    "\n[tags] - Search tags" \
    "\n[query] - Search query" \
    "\n[id] - Post ID" \
    "\n[login] - Image Board login or username" \
    "\n[key] - Image Board API key or password" \
    "\n\n<b>Inline search:</b>" \
    "\n<code>pools</code> [b] [page] [options] [name] - Pools search" \
    "\n<code>posts</code> [b] [page] [options] [tags] - Posts search" \
    "\n<code>tags</code> [b] [page] [options] [name] - Tags search" \
    "\n<code>shorts</code> [page] [options] [query] - Shortcuts search" \
    "\n\n<b>Search options:</b>" \
    "\na - Enable autopaging (lpts)" \
    "\nm - Show more metadata (p)" \
    "\np - Show gif/video as preview only (p)" \
    "\nq - Add quick buttons (lpts)" \
    "\nr - Reverse search order (s)" \
    "\nw - Match full words only (s)" \
    "\n\n<b>Inline commands:</b>" \
    "\n<code>help</code> - Send this message" \
    "\n<code>original</code> [b] [id] - Get original file of post" \
    "\n<code>post</code> [b] [id] - Get infromation of post" \
    "\n<code>short</code> [query] - Create inline shortcut" \
    "\n\n<b>Commands:</b>" \
    "\n/help - Send this message" \
    "\n/authorize [b] [login] [key] - Authorize to Image Board" \
    "\n/original [b] [id] - Get original file of post" \
    "\n/post [b] [id] - Get infromation of post" \
    "\n/short [query] - Create inline shortcut" \
    "\n/shorts - Manage saved shortcuts" \
    "\n/stop - Remove all your data" \
    "\n\n<b>Inline aliases:</b>" \
    "\n<code>l</code> - <code>pools</code>" \
    "\n<code>p</code> - <code>posts</code>" \
    "\n<code>t</code> - <code>tags</code>" \
    "\n<code>s</code> - <code>shorts</code>" \
    "\n\n<b>Inline examples:</b>" \
    "\n<code>p d 1 -a rating:g</code>" \
    "\n<code>t d *genshin*</code>" \
    "\n<code>original d 4507929</code>" \
    "\n<code>short p d -mq ringouulu</code>" \
    "\n\n<b>Supported Image Boards:</b>")"

for ib_board in ${ascii_table}
do
    . "${units}/ib_config.sh"
    . "${units}/ib_authconfig.sh"

    if [ -n "${ib_name}" ]
    then
        output_text="$(printf '%s\n%c - <a href="%s">%s</a>' "${output_text}" "${ib_board}" "${ib_url}" "${ib_name}")"

        for ib_mode in ${ascii_table}
        do
            . "${units}/ib_config.sh"

            if [ -n "${ib_data_url}" ]
            then
                ib_features="${ib_features}${ib_mode}"
            fi

            unset ib_data_url
        done

        if [ -n "${ib_config}" ]
        then
            output_text="$(printf "%s (auth)" "${output_text}")"
        fi

        if [ -n "${ib_features}" ]
        then
            output_text="$(printf "%s (%s)" "${output_text}" "${ib_features}")"
        fi
    fi

    unset ib_name ib_config ib_features
done
