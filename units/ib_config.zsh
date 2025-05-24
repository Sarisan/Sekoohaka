# Copyright (C) 2024-2025 Maria Lisina
# Copyright (C) 2024-2025 Danil Lisin
# SPDX-License-Identifier: Apache-2.0

ib_error_url="https://cdn.donmai.us/original/fb/b6/fbb6c45cac3194754dd1feb997cb8ad6.jpg"
ib_error_width=536
ib_error_height=516

case "${ib_board}" in
    (a|d)
        case "${ib_board}" in
            (a)
                ib_name="Safebooru"
                ib_api="https://safebooru.donmai.us"
                ib_url="https://safebooru.donmai.us"
            ;;
            (d)
                ib_name="Danbooru"
                ib_api="https://danbooru.donmai.us"
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
                ib_ifilename="cut -d '/' -f 7"
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
    ;;
    (g)
        ib_name="Gelbooru"
        ib_api="https://gelbooru.com"
        ib_url="https://gelbooru.com"

        ib_ratings=(
            safe safe
            general general
            sensitive sensitive
            questionable questionable
            explicit explicit
        )

        ib_groups=(
            tags Tags
        )

        case "${ib_mode}" in
            (p)
                ib_data_url="${ib_api}/index.php"
                ib_dfield1="page=dapi"
                ib_dfield2="s=post"
                ib_dfield3="q=index"
                ib_dfield4="json=1"
                ib_dlimit="limit"
                ib_dpage="pid"
                ib_dquery="tags"
                ib_iarray="post"
                ib_iid="id"
                ib_icreated="created_at"
                ib_isize="deprecated"
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
                ib_ioffset=-1
                ib_itzfield="-4,6-"
                ib_idate="%a %b %d %X %Y"
                ib_ifilename="cut -d '/' -f 7"
                ib_url="${ib_url}/index.php?page=post&s=view&id="
            ;;
            (t)
                ib_data_url="${ib_api}/index.php"
                ib_dfield1="page=dapi"
                ib_dfield2="s=tag"
                ib_dfield3="q=index"
                ib_dfield4="json=1"
                ib_dlimit="limit"
                ib_dpage="pid"
                ib_dquery="name_pattern"
                ib_iarray="tag"
                ib_iid="id"
                ib_itag="name"
                ib_icount="count"
                ib_iwildcard="%"
                ib_ioffset=-1
                ib_irecode="HTML"
                ib_url="${ib_url}/index.php?page=wiki&s=list&search="
            ;;
        esac
    ;;
    (i)
        ib_name="Idol Complex"
        ib_api="https://iapi.sankakucomplex.com"
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
    ;;
    (s)
        ib_name="Sankaku Channel"
        ib_api="https://sankakuapi.com"
        ib_url="https://chan.sankakucomplex.com"

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
                ib_url="${ib_url}/pools/"
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
                ib_url="${ib_url}/wiki/"
            ;;
        esac
    ;;
    (k|y)
        case "${ib_board}" in
            (k)
                ib_name="Konachan.com"
                ib_api="https://konachan.com"
                ib_url="https://konachan.com"
            ;;
            (y)
                ib_name="yande.re"
                ib_api="https://yande.re"
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
                ib_ifilename="sed 's/\/${ib_name}.*\./\./' | cut -d '/' -f 5"
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
    ;;
esac
