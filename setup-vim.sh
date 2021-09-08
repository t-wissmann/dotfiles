#!/bin/bash -e

::() {
    echo ":: $*" >&2
    "$@"
}

# utilities
fetch() {
    checksum="$3"
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
    fetch ~/.vim/colors/"${2:-$file}" "$1" "$3"
}

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
    :: vim --cmd "helptags $dir/doc" --cmd 'q' > /dev/null < /dev/null
}

#######################
##### colorthemes #####
#######################
#auto-colorscheme 'http://www.vim.org/scripts/download_script.php?src_id=17225' jellybeans.vim
#auto-colorscheme 'http://vimcolorschemetest.googlecode.com/svn/colors/autumnleaf.vim'
#auto-colorscheme 'http://vimcolorschemetest.googlecode.com/svn/colors/kate.vim'
#auto-colorscheme 'http://vimcolorschemetest.googlecode.com/svn/colors/tcsoft.vim'
auto-colorscheme 'https://github.com/altercation/vim-colors-solarized/raw/master/colors/solarized.vim'
#auto-colorscheme 'http://www.vim.org/scripts/download_script.php?src_id=9750' molokai.vim 
#auto-colorscheme 'https://vimcolorschemetest.googlecode.com/svn/colors/calmar256-dark.vim'
#auto-colorscheme 'https://raw.githubusercontent.com/chriskempson/base16-vim/master/colors/base16-default.vim'
#auto-colorscheme 'http://www.vim.org/scripts/download_script.php?src_id=11274' mustang.vim
#auto-colorscheme 'http://www.vim.org/scripts/download_script.php?src_id=8685' 256-jungle.vim
#auto-colorscheme 'https://raw.githubusercontent.com/Lokaltog/vim-distinguished/develop/colors/distinguished.vim'



###################
##### plugins #####
###################
#fetch ~/.vim/plugin/minibufexpl.vim \
#    'http://www.vim.org/scripts/download_script.php?src_id=3640'

#fetch ~/.vim/autoload/togglebg.vim \
#    'https://github.com/altercation/vim-colors-solarized/raw/master/autoload/togglebg.vim'

# for switching between header<->implementation
fetch ~/.vim/plugin/a.vim \
    'http://www.vim.org/scripts/download_script.php?src_id=7218'

# for doing mutt's abook query from vim
fetch ~/.vim/plugin/querycommandcomplete.vim \
    'http://www.vim.org/scripts/download_script.php?src_id=20369'

update-git https://github.com/morhetz/gruvbox ~/.vim/bundle/gruvbox
update-git https://github.com/kien/ctrlp.vim.git ~/.vim/bundle/ctrlp.vim
#update-git https://github.com/LaTeX-Box-Team/LaTeX-Box ~/.vim/bundle/LaTeX-Box.git
update-git https://github.com/lambdatoast/elm.vim ~/.vim/bundle/elm.vim.git
#update-git https://github.com/t-wissmann/minibufexpl.vim ~/.vim/bundle/minibufexpl

# update help tags for it
#vim --cmd 'helptags ~/.vim/bundle/LaTeX-Box.git/doc' --cmd 'q'
#vim --cmd 'helptags ~/.vim/bundle/elm.vim.git/doc' --cmd 'q'
#vim --cmd 'helptags ~/.vim/bundle/minibufexpl/doc' --cmd 'q'

#update-git https://github.com/bling/vim-airline ~/.vim/bundle/vim-airline
## update help tags for it
#vim --cmd 'helptags ~/.vim/bundle/vim-airline/doc' --cmd 'q'


