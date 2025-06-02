# Copyright (C) 2024-2025 Maria Lisina
# Copyright (C) 2024-2025 Danil Lisin
# SPDX-License-Identifier: Apache-2.0

ib_name="Gelbooru"
ib_config="gelbooru"
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
