#!/usr/bin/env bash

# scanning utility for my home printer...

device='epkowa:usb:005:002'
outfile="$1"
cmdname="$0"
shift

::() {
    echo ":: $*" >&2
    "$@"
}

usage() {
cat <<EOF
Usage: $cmdname TARGETIMAGE [SCANIMAGEARGS]

Scans from to the given TARGETIMAGE and passes the given SCANIMAGEARGS directly
to scanimage.
EOF
}

if [ -z "$outfile" ] ; then
    usage
    exit 1
fi

if [ -e "$outfile" ] ; then
    echo "Warning: $outfile exists already. Override?"
    read -n 1 -p " yn?" answer
    if [ ! "$answer" = y ] ; then
        exit 1
    fi
fi

:: scanimage -v -d "$device" --format=tiff \
    | :: convert - -page a4 -quality 81 "$outfile"
