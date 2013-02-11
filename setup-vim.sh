#!/bin/bash -e

fetch() {
    if ! [ -f "$1" ] ; then
        mkdir -p "${1%/*}"
        wget -O "$1" "$2"
        sed -i 's/\r//g' "$1"
    else
        echo "$1 already exists"
    fi
}

auto-colorscheme() {
    file="${1##*/}"
    fetch ~/.vim/colors/"$file" "$1"
}


fetch ~/.vim/plugin/minibufexpl.vim \
    'http://www.vim.org/scripts/download_script.php?src_id=3640'
fetch ~/.vim/colors/jellybeans.vim \
    'http://www.vim.org/scripts/download_script.php?src_id=17225'

fetch ~/.vim/colors/solarized.vim \
    'https://github.com/altercation/vim-colors-solarized/raw/master/colors/solarized.vim'
fetch ~/.vim/autoload/togglebg.vim \
    'https://github.com/altercation/vim-colors-solarized/raw/master/autoload/togglebg.vim'


fetch ~/.vim/colors/molokai.vim \
    'http://www.vim.org/scripts/download_script.php?src_id=9750'

auto-colorscheme 'http://vimcolorschemetest.googlecode.com/svn/colors/autumnleaf.vim'
auto-colorscheme 'http://vimcolorschemetest.googlecode.com/svn/colors/kate.vim'
auto-colorscheme 'http://vimcolorschemetest.googlecode.com/svn/colors/tcsoft.vim'

