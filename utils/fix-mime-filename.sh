#!/usr/bin/env bash

oldname="$1"
newname=$(perl -MEncode=from_to -pe 'from_to $_, "MIME-Header", "iso-8859-1"' <<< "$oldname")

::() {
    echo ":: $*" >&2
    "$@"
}

if [[ "$oldname" == "$newname" ]] ; then
    echo "no changes in \"$oldname\" regarding mime-encoding"
else
    echo "mv -i \"$oldname\" \"$newname\" ?"
    read -n 1 -p "[yn] " res
    echo
    if [[ "$res" == "y" ]] ; then
        :: mv -i "$oldname" "$newname"
    fi
fi
