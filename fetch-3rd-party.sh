#!/bin/bash -e


bins=(
    
)

::() {
    echo ":: $*" >&2
    "$@"
}

fetch() {
    dir="3rd-party/$1"
    if [ -d "$dir" ] ; then
        :: git --git-dir="$dir/.git" --work-tree="$dir" pull --ff-only
    else
        :: git clone "$2" "$dir"
    fi
    shift
    shift
    while x="$1" ; shift ; do
        file=$(:: find "$dir" -name "$x" | head -n 1)
        if [ -z "$file" ] ; then
            echo "Missing file: $x"
        else
            target="${file##*/}"
            target="${target%.py}"
            :: ln -sf "$(pwd)/$file" "$HOME/bin/$target"
        fi
    done
}

# example:
#fetch colortrans https://gist.github.com/MicahElliott/719710 \
#    colortrans.py

