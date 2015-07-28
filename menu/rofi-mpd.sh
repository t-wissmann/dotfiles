#!/bin/bash -e
# written by Thorsten Wißmann, 2015
#
# dependencies:
#
#  - rofi
#  - mpc
#  - bash
#  - standard unix utils (sed, column, grep, uniq,mkdir,tee,…)

# settings:
song_format="[[%title%\t[(by %artist%[ on %album%])]]|[%file%]]"
cachedir="$HOME/.cache/rofi-mpd"

# argument parsing
switcher="$1"
shift || true
args="$*"

# some utilities for gathering the switcher implementations
switcher_titles=( )
switcher_ids=( )
switchers=""
rofimpd="$0"

add_switcher() {
    switcher_titles+=( "$2" )
    switcher_ids+=( "$1" )
    switchers+="$2: $rofimpd $1,"
}

# caching behaviour
do_cached() {
    # execute the given command, but cache its output in a file named
    # $1 in $cachedir
    local cachename="$1"
    shift
    mkdir -p "$cachedir"
    date=$(mpc stats | grep 'DB Updated: ')
    file="$cachedir/$cachename"
    if [ "$(< $file.date)" = "$date" ] && [ -f "$file" ] ; then
        cat "$file"
    else
        "$@" | tee "$file"
        echo "$date" > $file.date
    fi
}

# to disable caching, just enable the following line
#do_cached() { shift; "$@" ; }

# switcher implementations
playlist() {
    print() {
        mpc --format "%position%\t$song_format" playlist \
            | sed 's,^\([^\t]*\t[^\t]\{40\}\)[^\t]*,\1…,' \
            | column -o ' ' -s $'\t' -t
    }
    execute() {
        pos="${*%% *}"
        mpc -q play "$pos"
    }
}

addsong() {
    uncached_print() {
        mpc --format "$song_format\t%file%" search filename '' \
            | sed 's,^\([^\t]\{40\}\)[^\t]*,\1…,' \
            | column -o $'\t' -s $'\t' -t
    }
    print() {
        do_cached addsong uncached_print
    }
    execute() {
        file="${*##*$'\t'}"
        mpc -q add "$file"
    }
}

addalbum() {
    uncached_print() {
        mpc --format '[%albumartist%|%artist%] — %album%' \
            search filename '' \
            | grep -v '^ — ' \
            | grep -v ' — $' \
            | uniq
    }
    print() {
        do_cached addalbum uncached_print
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

# switcher ordering + registration
add_switcher playlist   Playlist
add_switcher addalbum   "Add album"
add_switcher addsong    "Add song"

if [ -z "$switcher" ] ; then
    # if no switcher given, initiate rofi
    # also crop last comma added by last add_switcher call
    # first switcher automatically is activated
    rofi \
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
