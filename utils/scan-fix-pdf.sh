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

ask() {
    echo -n "==> $1 [y/n] "
    read -n 1 reply
    if [[ "${reply^^}" == 'Y' ]] ; then
        return 0
    else
        return 1
    fi
}

if [[ -z "$dpi" ]] ; then
    dpi=$(
        pdfimages -list "$sourcefile" |
            awk '{ if ($3 == "image") { print $13 ; exit } }'
    )
    echo "Auto-detecting DPI=$dpi"
fi

:: gs -dBATCH -dNOPAUSE -sDEVICE=jpeg -r"${dpi}x${dpi}" -sOutputFile="$tmpdir/p-%03d.jpg" "$sourcefile"

if ask "Create scan effect?" ; then
    echo
    for img in "$tmpdir"/p-*.jpg ; do
        rotation_values=( 0.1 0.15 -0.1 0.02 -0.02 -0.15 )
        rotation=${rotation_values[$((RANDOM%${#rotation_values[@]}))]}
        :: mogrify -background '#989898' -rotate "$rotation" -attenuate 0.25 +noise Gaussian "$img"
    done
else
    echo
fi

if ask "Make background white?" ; then
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
