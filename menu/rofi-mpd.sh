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

fix_date_format() {
    # reformats the date given in column $1 from format %c of locale LC_TIME=C
    # (see man strftime) to the format specified in argument $2 column indices
    # start with 1
    column_index="$1"
    gawk -F $'\t' '
    # parse a date which was formated using %c to unix time
    BEGIN {
        # generated by the following bash one-liner:
        # for i in {1..12} ; do LC_TIME=C date -d "1972-$i-01" +month2num[\"%b\"]\ =\ %_m ; done
        month2num["Jan"] =  1
        month2num["Feb"] =  2
        month2num["Mar"] =  3
        month2num["Apr"] =  4
        month2num["May"] =  5
        month2num["Jun"] =  6
        month2num["Jul"] =  7
        month2num["Aug"] =  8
        month2num["Sep"] =  9
        month2num["Oct"] = 10
        month2num["Nov"] = 11
        month2num["Dec"] = 12
    }
    function reformat_c_date(str) {
        monthname = gensub(/^([^ ]*)[ ]+([^ ]*)[ ]+([^ ]*)[ ]+([^ ]*)[ ]+([^ ]*)$/, "\\2", "g", str)
        monthnum = month2num[monthname]
        nicedate = gensub(/^([^ ]*)[ ]+([^ ]*)[ ]+([^ ]*)[ ]+([^ ]*)[ ]+([^ ]*)$/, "\\5 " monthnum " \\3 \\4", "g", str)
        nicedate = gensub(/:/, " ", "g", nicedate)
        return nicedate
    }

    {
        # modify the $column_index-th field
        $'"$1"' = strftime("'"$2"'", mktime(reformat_c_date($'"$1"')))
        print $0
    }
    '
}
# example usage:
# fix_date_format 2 '%Y-%m-%d %H:%M:%S'

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