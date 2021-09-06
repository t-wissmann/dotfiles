#!/usr/bin/env bash

set -e

usage() {
cat <<EOF
$0 DIR

List files in the directory DIR and its subdirectories in a rofi menu and open
the selected files. When selecting files via <Shift>-Return then the menu is
kept open.
EOF
}

dir="$1"
if [[ -z "$dir" ]] ; then
    usage >&2
    exit 1
fi

multiselectkey=$(rofi -h \
    | grep -m 1 -A1 '[-]kb-accept-alt' \
    | tail -n 1 \
    | awk '{print $1 ; }')

mesg="Type <i>$multiselectkey</i> to open multiple files."

rofiflags=(
    -dmenu
    -multi-select
    -i
    -p 'open'
    -mesg "$mesg"
)

find -L "$dir" -type f -printf '%P\n' \
    | grep -v '~$\|/\.\|^\.\|.swp$' \
    | sort \
    | rofi "${rofiflags[@]}" \
    | while read line ; do
        echo "$line"
        xdg-open "$dir/$line" 2> /dev/null 1> /dev/null &
    done




# vim: tw=80
