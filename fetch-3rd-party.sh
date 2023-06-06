#!/bin/bash -e


bins=(
    
)

::() {
    echo ":: $*" >&2
    "$@"
}

fetch() {
    dir="3rd-party/${1##*/}"
    if [ -d "$dir" ] ; then
        :: git --git-dir="$dir/.git" --work-tree="$dir" pull --ff-only
    else
        :: git clone "$1" "$dir"
    fi
    return 0
    # we don't link binaries at the moment
    #shift
    #shift
    #while x="$1" ; shift ; do
    #    file=$(:: find "$dir" -name "$x" | head -n 1)
    #    if [ -z "$file" ] ; then
    #        echo "Missing file: $x"
    #    else
    #        target="${file##*/}"
    #        target="${target%.py}"
    #        :: ln -sf "$(pwd)/$file" "$HOME/bin/$target"
    #    fi
    #done
}

:: mkdir -p ~/.urxvt/ext/
fetch https://github.com/regnarg/urxvt-config-reload
#fetch https://github.com/gessen/zsh-fzf-kill
:: ln -sf $HOME/dotfiles/3rd-party/urxvt-config-reload/config-reload ~/.urxvt/ext/

# example:
#fetch colortrans https://gist.github.com/MicahElliott/719710 \
#    colortrans.py

