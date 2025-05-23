# Copyright (C) 2024-2025 Maria Lisina
# Copyright (C) 2024-2025 Danil Lisin
# SPDX-License-Identifier: Apache-2.0

if [[ -n "${ib_file_url}" && "${ib_file_url}" != "null" ]]
then
    ib_sample_url="$(jq -r ".${ib_iarray}[${array_count}].${ib_isample}" "${ib_file}")"
    ib_preview_url="$(jq -r ".${ib_iarray}[${array_count}].${ib_ipreview}" "${ib_file}")"
    ib_width="$(jq -r ".${ib_iarray}[${array_count}].${ib_iwidth}" "${ib_file}")"
    ib_height="$(jq -r ".${ib_iarray}[${array_count}].${ib_iheight}" "${ib_file}")"
    ib_type="$(printf "%s" "${ib_file_url}" | eval ${ib_ifilename} | cut -d '.' -f 2)"

    if [[ "${ib_name}" = "Idol Complex" ]]
    then
        ib_file_url="https:${ib_file_url}"
    fi

    if [[ -z "${ib_sample_url}" || "${ib_sample_url}" = "null" ]]
    then
        ib_sample_url=${ib_file_url}
    elif [[ "${ib_name}" = "Idol Complex" ]]
    then
        ib_sample_url="https:${ib_sample_url}"
    fi

    if [[ -z "${ib_preview_url}" || "${ib_preview_url}" = "null" ]]
    then
        ib_preview_url=${ib_error_url}
    elif [[ "${ib_name}" = "Idol Complex" || "${ib_name}" = "Sankaku Channel" ]]
    then
        ib_preview_url="${ib_sample_url}"
    fi

    if [[ -n "${ib_width}" && "${ib_width}" != "null" && ${ib_width} -gt 0 ]]
    then
        ib_resolution_text="${ib_width}x${ib_height}"
    fi

    if [[ -n "${ib_type}" ]]
    then
        ib_type_text="$(printf "%s" "${ib_type}" | tr '[:lower:]' '[:upper:]')"
    fi

    case "${ib_type}" in
        (jpeg | jpg | png | webp)
            ib_type="photo"
        ;;
        (gif)
            . "${units}/ib_preview.zsh"
            ib_type="gif"
        ;;
        (mp4)
            . "${units}/ib_preview.zsh"
            ib_type="video"
        ;;
        (zip | webm)
            . "${units}/ib_sample.zsh"
        ;;
        (*)
            ib_sample_url="${ib_error_url}"
            ib_preview_url="${ib_error_url}"
            ib_width="${ib_error_width}"
            ib_height="${ib_error_height}"
            ib_type="photo"
        ;;
    esac
else
    ib_file_size=0
    ib_file_url="${ib_error_url}"
    ib_sample_url="${ib_error_url}"
    ib_preview_url="${ib_error_url}"
    ib_width="${ib_error_width}"
    ib_height="${ib_error_height}"
    ib_type="photo"
fi

if [[ -n "${ib_file_size}" && "${ib_file_size}" != "null" && ${ib_file_size} -gt 0 ]]
then
    if [[ ${ib_file_size} -gt 20971520 && "${ib_sample_url}" = "${ib_file_url}" ]]
    then
        . "${units}/ib_sample.zsh"
    fi

    unit_offset=0
    size_offset=1.0

    for unit in B KiB MiB GiB TiB PiB
    do
        unit_offset=${size_offset}
        size_offset=$((size_offset * 1024))

        if [[ ${ib_file_size} -lt ${size_offset} ]]
        then
            break
        fi
    done

    if [[ ${ib_file_size} -ge 1024 ]]
    then
        ib_size_text="$(printf "%.2f %s" "$((ib_file_size / unit_offset))" "${unit}")"
    else
        ib_size_text="$(printf "%u %s" "${ib_file_size}" "${unit}")"
    fi
fi
