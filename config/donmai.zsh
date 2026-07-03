# Copyright (C) 2024-2026 Maria Lisina
# Copyright (C) 2024-2026 Danil Lisin
# SPDX-License-Identifier: Apache-2.0

ib_cname="donmai"

ib_header="Authorization: Baisc"
ib_login_file="login"
ib_key_file="api_key"
ib_login_word="login"
ib_key_word="API key"

case "${ib_board}" in
    (a)
        ib_name="Safebooru"
        ib_config="safebooru"
        ib_api="https://safebooru.donmai.us"
        ib_auth="https://safebooru.donmai.us"
        ib_url="https://safebooru.donmai.us"
    ;;
    (d)
        ib_name="Danbooru"
        ib_config="danbooru"
        ib_api="https://danbooru.donmai.us"
        ib_auth="https://danbooru.donmai.us"
        ib_url="https://danbooru.donmai.us"
    ;;
esac

ib_ratings=(
    g general
    s sensitive
    q questionable
    e explicit
)

ib_groups=(
    tag_string_artist Artist
    tag_string_copyright Copyright
    tag_string_character Character
    tag_string_general General
    tag_string_meta Meta
)

case "${ib_mode}" in
    (l)
        ib_data_url="${ib_api}/pools.json"
        ib_dlimit="limit"
        ib_dpage="page"
        ib_dquery="search[name_matches]"
        ib_iid="id"
        ib_icreated="created_at"
        ib_ipool="name"
        ib_icount="post_count"
        ib_idate="%Y-%m-%dT%X"
        ib_ispace="_"
        ib_iorder="order:created_at_asc"
        ib_url="${ib_url}/pools/"
    ;;
    (p)
        ib_data_url="${ib_api}/posts.json"
        ib_dlimit="limit"
        ib_dpage="page"
        ib_dquery="tags"
        ib_iid="id"
        ib_icreated="created_at"
        ib_isize="file_size"
        ib_ifile="file_url"
        ib_isample="large_file_url"
        ib_ipreview="preview_file_url"
        ib_iwidth="image_width"
        ib_iheight="image_height"
        ib_irating="rating"
        ib_iparent="parent_id"
        ib_ichildren="has_children"
        ib_imd5="md5"
        ib_isource="source"
        ib_itags="tag_string"
        ib_idate="%Y-%m-%dT%X"
        ib_url="${ib_url}/posts/"
    ;;
    (t)
        ib_data_url="${ib_api}/tags.json"
        ib_dlimit="limit"
        ib_dpage="page"
        ib_dquery="search[name_matches]"
        ib_iid="id"
        ib_itag="name"
        ib_icount="post_count"
        ib_irecode="HTML"
        ib_url="${ib_url}/wiki_pages/"
    ;;
esac
