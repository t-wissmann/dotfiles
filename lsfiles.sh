#!/bin/bash

# list all relevant files for specified hostname
hostname="$1"

gitdir="$HOME/dotfiles"
source "$gitdir/config.sh"

for i in ${!files[@]} ; do
    echo "${files[$i]}"
done



