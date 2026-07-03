# Copyright (C) 2024-2026 Maria Lisina
# Copyright (C) 2024-2026 Danil Lisin
# SPDX-License-Identifier: Apache-2.0

ib_cname="moebooru"

ib_raw=0
ib_login_file="username"
ib_key_file="api_key"
ib_login_word="username"
ib_key_word="API key"

case "${ib_board}" in
    (k)
        ib_name="Konachan"
        ib_config="konachan"
        ib_api="https://konachan.com"
        ib_auth="https://konachan.com"
        ib_url="https://konachan.com"
    ;;
    (y)
        ib_name="Yandere"
        ib_config="yandere"
        ib_api="https://yande.re"
        ib_auth="https://yande.re"
        ib_url="https://yande.re"
    ;;
esac

ib_ratings=(
    s safe
    q questionable
    e explicit
)

ib_groups=(
    tags Tags
)

case "${ib_mode}" in
    (l)
        ib_data_url="${ib_api}/pool.json"
        ib_dlimit="limit"
        ib_dpage="page"
        ib_dquery="query"
        ib_iid="id"
        ib_icreated="created_at"
        ib_ipool="name"
        ib_icount="post_count"
        ib_idate="%Y-%m-%dT%X"
        ib_ispace="_"
        ib_url="${ib_url}/pool/show/"
    ;;
    (p)
        ib_data_url="${ib_api}/post.json"
        ib_dlimit="limit"
        ib_dpage="page"
        ib_dquery="tags"
        ib_iid="id"
        ib_icreated="created_at"
        ib_isize="file_size"
        ib_ifile="file_url"
        ib_isample="sample_url"
        ib_ipreview="preview_url"
        ib_iwidth="width"
        ib_iheight="height"
        ib_irating="rating"
        ib_iparent="parent_id"
        ib_ichildren="has_children"
        ib_imd5="md5"
        ib_isource="source"
        ib_itags="tags"
        ib_url="${ib_url}/post/show/"
    ;;
    (t)
        ib_data_url="${ib_api}/tag.json"
        ib_dlimit="limit"
        ib_dpage="page"
        ib_dquery="name"
        ib_iid="id"
        ib_itag="name"
        ib_icount="count"
        ib_irecode="UTF-8"
        ib_url="${ib_url}/wiki/show?title="
    ;;
esac
