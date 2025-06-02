# Copyright (C) 2024-2025 Maria Lisina
# Copyright (C) 2024-2025 Danil Lisin
# SPDX-License-Identifier: Apache-2.0

ib_name="Idol Complex"
ib_config="idolcomplex"
ib_api="https://idol.sankakucomplex.com"
ib_url="https://idol.sankakucomplex.com"

ib_ratings=(
    s safe
    q questionable
    e explicit
)

ib_groups=(
    "tags[]|select(.type==1)|.name" Idol
    "tags[]|select(.type==2)|.name" Studio
    "tags[]|select(.type==3)|.name" Copyright
    "tags[]|select(.type==4)|.name" Character
    "tags[]|select(.type==6)|.name" Genre
    "tags[]|select(.type==5)|.name" Set
    "tags[]|select(.type==0)|.name" General
    "tags[]|select(.type==8)|.name" Medium
    "tags[]|select(.type==9)|.name" Meta
)

case "${ib_mode}" in
    (l)
        ib_data_url="${ib_api}/pools.json"
        ib_dlimit="limit"
        ib_dpage="page"
        ib_dquery="name"
        ib_iid="id"
        ib_icreated="created_at"
        ib_ipool="name"
        ib_icount="post_count"
        ib_idate="%Y-%m-%d %H:%M"
        ib_ispace="_"
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
        ib_isample="sample_url"
        ib_ipreview="preview_url"
        ib_iwidth="width"
        ib_iheight="height"
        ib_irating="rating"
        ib_iparent="parent_id"
        ib_ichildren="has_children"
        ib_imd5="md5"
        ib_isource="deprecated"
        ib_itags="tags[].name"
        ib_idate="%Y-%m-%dT%X"
        ib_ifilename="cut -d '?' -f 1 | cut -d '/' -f 7"
        ib_url="${ib_url}/posts/"
    ;;
    (t)
        ib_data_url="${ib_api}/tags.json"
        ib_dlimit="limit"
        ib_dpage="page"
        ib_dquery="name"
        ib_iid="id"
        ib_itag="name"
        ib_icount="count"
        ib_irecode="UTF-8"
        ib_url="${ib_url}/wiki/"
    ;;
esac
