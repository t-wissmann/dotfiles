#!/bin/bash


# settings
gitdir="$HOME/dotfiles"
source "$gitdir/config.sh"

dryrun="${dryrun:-1}" # 0 for real run



#### MAIN ####

function is_real_file() {
    local path="$1"
    # check if it 
    [ -e "$path" ] && ! [ -L "$path" ] && return 1
    return 0
}

function create_link() {
    # creates a link for file $1
    origfile="$1"
    origfile_basename="${1##*/}"
    # path relativ to git dir
    relpath="$1"
    absolutepath="$gitdir/$relpath"
    targetpath="$relpath"
    for i in ${!relpath2target[@]} ; do
        #echo sed "${relpath2target[$i]}"
        targetpath=$(echo "$targetpath"|sed "${relpath2target[$i]}")
    done
    if ! [ -e "$absolutepath" ] ; then
        echo -e "${color_skip} SKIPPING ${color_source} $origfile" \
                "${color_default}because it does not exist"
        return 1
    fi
    if ! is_real_file "$targetpath" ; then
        echo -e "${color_skip} SKIPPING ${color_source} $origfile" \
                 "${color_default}because ${color_target}$targetpath" \
                 "${color_default}is real file"
    else
        origfile_aligned=$(printf "%${origfile_width}s" "$origfile")
        echo -e "$color_link LINKING  $color_source $origfile_aligned" \
                "$color_link=> $color_target$targetpath$color_default"
        [ "$dryrun" = 0 ] && ln -n -f -s "$absolutepath" "$targetpath" || return 1
    fi
    return 0
}


if [ "$1" = "-" ] ; then
    while read i ; do
        i=$(echo "$i"|sed "s#/*\$##") # remove all slashes at the end
        create_link "$i"
    done
else
    for i in $* ; do
        i=$(echo "$i"|sed "s#/*\$##") # remove all slashes at the end
        create_link "$i"
    done
fi

exit 0

