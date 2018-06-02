#!/usr/bin/env bash

# cat the given PDFs in such a way such that all PDF parts
# start on odd page numbers (i.e. on the right sheet side when printing it in
# duplex). this is achieved by inserting blank a4 pages

set -e

::() {
    echo ":: $*"
    "$@"
}

output=output.pdf
blank=$(mktemp --suffix=.pdf)
:: convert xc:none -page A4 "$blank"

options=1
while [[ "$options" -eq 1 ]] ; do
    doshift=1
    case "$1" in
        -o)
            shift
            output="$1"
            ;;
        --output=*)
            output="${1#--output=}"
            ;;
        --)
            options=0
            ;;
        *)
            options=0
            doshift=0
            ;;
    esac
    if [[ "$doshift" -eq 1 ]] ; then
        shift
    fi
done


FILES=(
)
for i in "$@" ; do
    pages=$(LC_ALL=C pdfinfo "$i" | grep '^Pages:' | cut -d':' -f2)
    FILES+=( "$i" )
    printf "# %2d pages for: %s \n" "$pages" "$i"
    if [[ "$((pages%2))" -eq 1 ]] ; then
        FILES+=( "$blank" )
    fi
done

:: pdftk "${FILES[@]}" cat output "$output"
:: rm "$blank"

