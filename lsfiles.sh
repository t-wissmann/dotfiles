#!/bin/bash

# list all relevant files for specified hostname
hostname="$1"

files=(
    bashrc
    bash.d
    Xdefaults
    ncmpcpp-config
    config/*
)

for i in ${!files[@]} ; do
    echo "${files[$i]}"
done



