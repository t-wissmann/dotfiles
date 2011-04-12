#!/bin/bash

# functions
function array2str() {
    local arrayname="$1"
    local isfirst=1
    for i in $(eval "echo \${!$arrayname[@]}") ; do
        [ $isfirst = 1 ] && isfirst=0 || echo -n '\|'
        eval "echo -n \${$arrayname[$i]}"
    done
}


# settings
gitdir="$HOME/dotfiles"

homedir=(
    bashrc
    bash.d
    Xdefaults
)

color_skip="\e[0;1;41m"
color_source="\e[0m\e[1;36m"
color_target="\e[0m\e[0;34m"
color_default="\e[0m"
color_link="\e[0m\e[0;32m"

relpath2target=(
    # just a list of sed commands
    "s#^\($(array2str homedir)\)\$#$HOME/.\1#"
    "s#^config/\(.*\)\$#$HOME/.config/\1#"
    "s#^ncmpcpp-config#$HOME/.ncmpcpp/config#"
)

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
        echo -e "$color_link LINKING  $color_source $origfile" \
                "$color_link=> $color_target$targetpath$color_default"
        [ "$dryrun" = 0 ] && ln -f -s "$absolutepath" "$targetpath" || return 1
    fi
    return 0
}


for i in $* ; do
    i=$(echo "$i"|sed "s#/*\$##") # remove all slashes at the end
    create_link "$i"
done


exit 0

