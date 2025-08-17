# Copyright (C) 2024-2025 Maria Lisina
# Copyright (C) 2024-2025 Danil Lisin
# SPDX-License-Identifier: Apache-2.0

case "${ib_board}" in
    (i)
        ib_name="Idol Complex"
        ib_config="idolcomplex"
        ib_api="https://i.sankakuapi.com"
        ib_url="https://www.idolcomplex.com"
    ;;
    (s)
        ib_name="Sankaku Channel"
        ib_config="sankakuchannel"
        ib_api="https://sankakuapi.com"
        ib_url="https://www.sankakucomplex.com"
    ;;
esac

ib_ratings=(
    s safe
    q questionable
    e explicit
)

ib_groups=(
    "tags[]|select(.type==1)|.tagName" Artist
    "tags[]|select(.type==2)|.tagName" Studio
    "tags[]|select(.type==3)|.tagName" Copyright
    "tags[]|select(.type==4)|.tagName" Character
    "tags[]|select(.type==5)|.tagName" Genre
    "tags[]|select(.type==0)|.tagName" General
    "tags[]|select(.type==8)|.tagName" Medium
    "tags[]|select(.type==9)|.tagName" Meta
)

case "${ib_mode}" in
    (l)
        ib_data_url="${ib_api}/pools"
        ib_dlimit="limit"
        ib_dpage="page"
        ib_dquery="name"
        ib_iid="id"
        ib_icreated="created_at"
        ib_ipool="name"
        ib_icount="post_count"
        ib_idate="%Y-%m-%d %H:%M"
        ib_url="${ib_url}/books/"
    ;;
    (p)
        ib_data_url="${ib_api}/posts"
        ib_dlimit="limit"
        ib_dpage="page"
        ib_dquery="tags"
        ib_iid="id"
        ib_icreated="created_at.s"
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
        ib_itags="tags[].tagName"
        ib_ifilename="cut -d '?' -f 1 | cut -d '/' -f 7"
        ib_url="${ib_url}/posts/"
    ;;
    (t)
        ib_data_url="${ib_api}/tags"
        ib_dlimit="limit"
        ib_dpage="page"
        ib_dquery="name"
        ib_iid="id"
        ib_itag="tagName"
        ib_icount="post_count"
        ib_url="${ib_url}/tags/"
    ;;
esac
