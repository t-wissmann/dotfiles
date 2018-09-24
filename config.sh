#!/bin/bash


function array2str() {
    local arrayname="$1"
    local isfirst=1
    for i in $(eval "echo \${!$arrayname[@]}") ; do
        [ $isfirst = 1 ] && isfirst=0 || echo -n '\|'
        eval "echo -n \${$arrayname[$i]}"
    done
}

is_cip() {
    case "$HOSTNAME" in
        faui0*)
            return 0
            ;;
        *)
            return 1
            ;;
    esac
}

homedir=(
    bash.d
    bashrc
    zshrc
    zprofile
    calcrc
    dialogrc
    gitconfig
    tigrc
    #emacs
    #emacs.d
    pinforc
    ghci
    screenrc
    latexmkrc
    tmux.conf
    vimrc
    vitrc
    inputrc
    gvimrc
    spacemacs
    $(is_cip && echo taskrc.cip || echo taskrc)
    Xdefaults{,.d}
    abcde.conf
)

files=(
    config/*[^~]
    config/qutebrowser/userscripts
    finch-gntrc
    ${homedir[@]}
    ncmpcpp-config
    mplayer.conf
    gpg.conf
)


relpath2target=(
    # just a list of sed commands
    "s#taskrc\.cip#$HOME/.taskrc#"
    "s#^\($(array2str homedir)\)\$#$HOME/.\1#"
    "s#^ncmpcpp-config#$HOME/.ncmpcpp/config#"
    "s#^gpg.conf#$HOME/.gnupg/gpg.conf#"
    "s#^finch-gntrc#$HOME/.gntrc#"
    "s#^mplayer.conf#$HOME/.mplayer/config#"
    "s,^config/qutebrowser/userscripts,$HOME/.local/share/qutebrowser/userscripts,"
    "s#^config/\(.*\)\$#$HOME/.config/\1#"
)

# options
origfile_width="-20"

# colors
color_skip="\e[0;1;41m"
color_source="\e[0m\e[1;36m"
color_target="\e[0m\e[0;34m"
color_default="\e[0m"
color_link="\e[0m\e[0;32m"


