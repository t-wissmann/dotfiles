#!/usr/bin/env bash

cmdname="$0"

usage() {
cat <<EOF
Usage: $cmdname

In a stack project with a cabal file, create a directory
bin/ containing links to all built executables.
EOF
}

shopt -s nullglob

cabals=( *.cabal )

if [[ ${#cabals[@]} -eq 0 ]] ; then
    echo "No cabal files found, exiting."
    exit 1
fi

mkdir -p bin/

for c in "${cabals[@]}" ; do
    executables=( $(grep -oE 'executable [^ ]*' "$c"|cut -d' ' -f2) )
    for e in "${executables[@]}" ; do
        if [[ -d ".stack-work" ]] ; then
            path=`stack exec which "$e" 2> /dev/null`
            if [[ "$?" -ne 0 ]] ; then
                echo "$e not found by stack. skipping."
                continue
            fi
            target="bin/$e"
            if [[ -e "$target" ]] && ! [[ -h "$target" ]] ; then
                echo "$target exists but is no link. skipping."
                continue
            fi
            ln -v -r -sf "$path" "bin/$e"
        fi
    done
done

# vim: tw=80
