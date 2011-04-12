#!/bin/bash


function array2str() {
    local arrayname="$1"
    local isfirst=1
    for i in $(eval "echo \${!$arrayname[@]}") ; do
        [ $isfirst = 1 ] && isfirst=0 || echo -n '\|'
        eval "echo -n \${$arrayname[$i]}"
    done
}

homedir=(
    bashrc
    bash.d
    screenrc
    vimrc
    calcrc
    tmux.conf
    pinforc
    Xdefaults{,.d}
    gitconfig
)

files=(
    ${homedir[@]}
    ncmpcpp-config
    config/*
    finch-gntrc
)


relpath2target=(
    # just a list of sed commands
    "s#^\($(array2str homedir)\)\$#$HOME/.\1#"
    "s#^config/\(.*\)\$#$HOME/.config/\1#"
    "s#^ncmpcpp-config#$HOME/.ncmpcpp/config#"
    "s#^finch-gntrc#$HOME/.gntrc#"
)

# options
origfile_width="-20"

# colors
color_skip="\e[0;1;41m"
color_source="\e[0m\e[1;36m"
color_target="\e[0m\e[0;34m"
color_default="\e[0m"
color_link="\e[0m\e[0;32m"


