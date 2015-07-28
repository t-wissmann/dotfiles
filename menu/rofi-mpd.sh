#!/bin/bash -e

#song_format="%position%) [[[%artist% - ]%title%[ (%album%)]]|[%file%]]"
song_format="[[%title%\t[(by %artist%[ on %album%])]]|[%file%]]"

switcher="$1"
shift || true
args="$*"

case "$switcher" in
    playlist)
        if [ -z "$args" ] ; then
            mpc --format "%position%\t$song_format" playlist \
                | sed 's,^\([^\t]*\t[^\t]\{40\}\)[^\t]*,\1…,' \
                | column -s $'\t' -t
        else
            pos="${args%% *}"
            mpc -q play "$pos"
        fi
        ;;
    addsong)
        if [ -z "$args" ] ; then
            mpc --format "$song_format\t%file%" search filename '' \
                | sed 's,^\([^\t]\{40\}\)[^\t]*,\1…,' \
                | column -s $'\t' -t
        else
            echo "add $args" >&2
        fi
        ;;
    addalbum)
        if [ -z "$args" ] ; then
            mpc --format '[%albumartist%|%artist%] — %album%' \
                search filename '' \
                | grep -v '^ — ' \
                | grep -v ' — $' \
                | uniq
        else
            artist="${args%% — *}"
            album="${args#* — }"
            output=$(mpc find albumartist "$artist" album "$album")
            if [ -n "$output" ] ; then
                # if output was empty, then $artist was the album artist
                # if $artist was albumartist, then add by albumartist
                mpc -q findadd albumartist "$artist" album "$album"
            else
                # else add using the artist tag
                mpc -q findadd artist "$artist" album "$album"
            fi
        fi
        ;;
    "")
        rofi  -no-levenshtein-sort \
            -switchers "Playlist:$0 playlist,Add album:$0 addalbum,Add song:$0 addsong" \
            -mode Playlist,Add\ Album,Add\ song -show Playlist
        ;;
esac


