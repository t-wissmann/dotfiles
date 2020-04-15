#!/bin/bash -e


socket="$HOME/.mpv/mpv-append-socket"
if ! [ -d "${socket%/*}" ] ; then
    mkdir -v -p "${socket%/*}" >&2
fi
file="$1"
if ! [[ "$file" =~ ^[/] ]] ; then
    # if the filepath is not absolute
    # then prepend the current directory
    file="$PWD/$file"
fi
filebase="${file##*/}"

if [ -S "$socket" ] && [ -n "$(pidof mpv)$" ] ; then
    # if socket already exists and mpv is still running,
    # communicate with the mpv instance
    cat <<EOF | socat - "$socket"
loadfile "${file//\"/\\\"}" append
show_text "+= ${filebase//\"/\\\"}"
EOF
else
    # otherwise, start mpd
    mpv --keep-open=yes --force-window=immediate --input-unix-socket="$socket" "$@" || true
    # and clean up the socket afterwards
    rm "$socket"
fi

