#!/bin/bash -e

# set up ~/.vim-folder
mkdir -p ~/.vim/plugin

fetch() {
    if ! [ -f "$1" ] ; then
        wget -O "$1" "$2"
    else
        echo "$1 already exists"
    fi
}

fetch ~/.vim/plugin/minibufexpl.vim \
    'http://www.vim.org/scripts/download_script.php?src_id=3640'
