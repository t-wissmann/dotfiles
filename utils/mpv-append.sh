#!/bin/bash -e

debug() {
    #echo ":: $*" >&2
    true
}

socket="$HOME/.config/mpv/mpv-append-socket"
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
pid=$(pidof mpv) || true
if [ -S "$socket" ] && [ -n "$(pidof mpv)" ] ; then
    # if socket already exists and mpv is still running,
    # communicate with the mpv instance
    debug "Sending to mpv pid $pid"
    cat <<EOF | socat - "$socket"
loadfile "${file//\"/\\\"}" append
show_text "+= ${filebase//\"/\\\"}"
EOF
else
    # otherwise, start mpd
    debug "Opening in new instance"
    # old option name: --input-unix-socket
    mpv --keep-open=yes --force-window=immediate --input-ipc-server="$socket" "$@" || true
    # and clean up the socket afterwards
    rm "$socket"
fi

