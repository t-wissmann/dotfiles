#!/bin/bash -e

# set up ~/.vim-folder
mkdir -p ~/.vim/plugin

fetch() {
    if ! [ -f "$1" ] ; then
        mkdir -p "${1%/*}"
        wget -O "$1" "$2"
    else
        echo "$1 already exists"
    fi
}

fetch ~/.vim/plugin/minibufexpl.vim \
    'http://www.vim.org/scripts/download_script.php?src_id=3640'
fetch ~/.vim/colors/jellybeans.vim \
    'http://www.vim.org/scripts/download_script.php?src_id=17225'

fetch ~/.vim/colors/solarized.vim \
    'https://github.com/altercation/vim-colors-solarized/raw/master/colors/solarized.vim'
