#!/bin/bash -e

::() { echo -e ":: $*" >&2 ; } ; export -f ::
export srcdir="$1"
export destdir=./

importfile() {
    shopt -s nocasematch
    case "$1" in
        *.mp3|*.jpg|*.lyrics|*.txt)
            outfile="$1"
            CMD=( ln -f )
            ;;
        *.jpeg)
            outfile="${1%.jpeg}.jpg"
            CMD=( ln -f )
            ;;
        *.png)
            outfile="${1%.jpeg}.jpg"
            CMD=( ln -f )
            ;;
        *.flac)
            outfile="${1%.mp3}.flac"
            CMD=( ~/dotfiles/utils/flac2mp3.sh )
            ;;
        *.wav|*.mood)
            # silently ignore some file types
            return
            ;;
        *.*)
            :: "Ignoring unknown filetype \e[1m*.${1##*.}\e[0m: ${1}"
            return
            ;;
    esac
    outfile="$destdir/$outfile"
    infile="$1"
    if [ -f "$outfile" -a "$infile" -ot "$outfile" ] ; then
        # if outfile exists and infile is not newer,
        # then outfile is up to date
        return
    fi
    #:: "$1 -> $outfile"
    #:: "${CMD[@]}" "$infile" "$outfile" # || return 1
}
export -f importfile

find "$1" -type f -printf '%P\n' | parallel importfile
