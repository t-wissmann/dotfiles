#!/usr/bin/env bash

tmpdir=`mktemp -d`
sourcefile="$1"
targetfile="${2:-${1%%.pdf}-fixed.pdf}"
dpi=${dpi}
utils=$HOME/dotfiles/utils

::() {
    echo -e "\e[1;33m:: \e[0;32m$*\e[0m" >&2
    "$@"
}

if [[ -z "$dpi" ]] ; then
    dpi=$(
        pdfimages -list "$sourcefile" |
            awk '{ if ($3 == "image") { print $13 ; exit } }'
    )
    echo "Auto-detecting DPI=$dpi"
fi

:: gs -dBATCH -dNOPAUSE -sDEVICE=jpeg -r"${dpi}x${dpi}" -sOutputFile="$tmpdir/p-%03d.jpg" "$sourcefile"

if read -n 1 -p "Make background white? [yN]" res && [[ "${res//Y/y}" = y ]] ; then
    echo
    export THRESHOLD=${THRESHOLD:-80}
    :: $utils/scan-fix-white-bg.sh "$tmpdir"/p-*.jpg
else
    echo
fi

export DPI="$dpi"
export pdf="$targetfile"
:: $utils/ocr "$tmpdir"/p-*.jpg

if [[ -n "${tmpdir##//}" ]] ; then
    :: rm -r "$tmpdir/"
fi
