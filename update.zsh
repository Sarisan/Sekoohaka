#!/usr/bin/env zsh

__renamed=(
    short shorts
    idol idolcomplex
    sankaku sankakuchannel
    cookies.txt cookies
)

while [[ ${#__renamed} -ge 2 ]]
do
    for __file in $(find users -name "${__renamed[1]}")
    do
        mv "${__file}" "${__file%/*}/${__renamed[2]}"
        echo "${__file} -> ${__file%/*}/${__renamed[2]}"
    done

    shift 2 __renamed
done
