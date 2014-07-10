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
}

install-git() {
    local url="$1"
    local dir="$2"
    update-git "$url" "$dir"
    shopt -s nullglob
    for subdir in indent plugin doc syntax ftplugin ftdetect ; do
        mkdir -p "$subdir"/
        for file in "$dir/$subdir/"* ; do
            cp -v "$file" "$subdir"/ || true
        done
    done
}

(
    cd ~/.vim/

    update-git https://github.com/kien/ctrlp.vim.git bundle/ctrlp.vim
    # update help tags for it
    vim --cmd 'helptags ~/.vim/bundle/ctrlp.vim/doc' --cmd 'q'


    install-git https://github.com/jvoorhis/coq.vim coq
    install-git git://github.com/chrisbra/csv.vim.git csv
    # install-git https://github.com/jesboat/CoqIDE/ CoqIDE
    install-git https://github.com/eagletmt/coqtop-vim coqtop
    mkdir -p indent
    pushd indent
        ln -sf ../coq/indent/coq.vim .
    popd
    #mkdir -p plugin
    #pushd plugin
    #    ln -sf ../coqtop/plugin/coqtop.vim .
    #popd
    #mkdir -p autoload
    #pushd autoload
    #    ln -sf ../coqtop/autoload/coqtop.vim .
    #popd
    mkdir -p syntax
    pushd syntax
        ln -sf ../coq/syntax/coq.vim .
    popd

)

