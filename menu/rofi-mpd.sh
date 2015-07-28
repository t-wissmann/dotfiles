#!/bin/bash -e

#song_format="%position%) [[[%artist% - ]%title%[ (%album%)]]|[%file%]]"
song_format="[[%title%\t[(by %artist%[ on %album%])]]|[%file%]]"

switcher="$1"
shift || true
args="$*"

switcher_titles=( )
switcher_ids=( )
switchers=""
rofimpd="$0"

add_switcher() {
    switcher_titles+=( "$2" )
    switcher_ids+=( "$1" )
    switchers+="$2: $rofimpd $1,"
}

playlist() {
    print() {
        mpc --format "%position%\t$song_format" playlist \
            | sed 's,^\([^\t]*\t[^\t]\{40\}\)[^\t]*,\1…,' \
            | column -s $'\t' -t
    }
    execute() {
        pos="${*%% *}"
        mpc -q play "$pos"
    }
}

addsong() {
    print() {
        mpc --format "$song_format\t%file%" search filename '' \
            | sed 's,^\([^\t]\{40\}\)[^\t]*,\1…,' \
            | column -s $'\t' -t
    }
    execute() {
        echo "add $*" >&2
    }
}

addalbum() {
    print() {
        mpc --format '[%albumartist%|%artist%] — %album%' \
            search filename '' \
            | grep -v '^ — ' \
            | grep -v ' — $' \
            | uniq
    }
    execute() {
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
    }
}

add_switcher playlist   Playlist
add_switcher addalbum   "Add album"
add_switcher addsong    "Add song"

if [ -z "$switcher" ] ; then
    rofi  -no-levenshtein-sort \
        -switchers "${switchers%,}" \
        -show "${switcher_titles[0]}"
else
    # check whether given $switcher is a valid switcher id
    for s in "${switcher_ids[@]}" ; do
        if [ "$s" = "$switcher" ] ; then
            # load switcher
            $s
            if [ -z "$args" ] ; then
                # if no args given to switcher the print items
                print
            else
                # otherwise pass args to switcher
                execute "$args"
            fi
            exit 0
        fi
    done
fi
