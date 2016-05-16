#!/bin/bash


file="$1"
filename="${file##*/}"
basedir="${file%/*}"

extensions=(
    jpg jpeg gif png
    tif bmp
    )

extregexp=$(printf "|.*.%s" "${extensions[@]}")
extregexp=${extregexp#|}

readarray -t list < <(
    find -H "$basedir" -maxdepth 1 -xtype f -printf '%P\n' \
        | grep -iE "$extregexp" \
        | sort -f
)

# find index of $file in $list
idx=0
for i in ${!list[@]} ; do
    if [ "${list[$i]}" = "$filename" ] ; then
        idx=$i
        break
    fi
done

show_notifications() {
    while read line ; do
        notify-send "SXIV ${basedir##*/}" "$line"
    done
}

printf "${basedir//%/%%}/%s\n" "${list[@]}" | sxiv -a -i -n "$((idx+1))" 2>&1 \
    | show_notifications



