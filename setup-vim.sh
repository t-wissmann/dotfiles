#!/bin/bash -e

fetch() {
    if ! [ -f "$1" ] ; then
        mkdir -p "${1%/*}"
        wget -O "$1" "$2"
        case "$1" in
            *.vim) sed -i 's/\r//g' "$1" ;;
            *.tgz) (
                cd "${1%/*}"
                tar xvf "${1##*/}"
            )
            ;;
        esac
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

update-git() {
    local url="$1"
    local dir="$2"
    if [ -d "$dir" ] ; then
        pushd "$dir"
        git pull
        popd
    else
        git clone "$url" "$dir"
    fi
    shopt -s nullglob
    for subdir in indent plugin doc syntax ftplugin ftdetect ; do
        for file in "$dir/$subdir/"* ; do
            cp -v "$file" "$subdir"/
        done
    done
}

(
    cd ~/.vim/

    update-git https://github.com/jesboat/CoqIDE/ CoqIDE
    update-git https://github.com/jvoorhis/coq.vim coq
    update-git git://github.com/chrisbra/csv.vim.git csv
)

