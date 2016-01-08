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
        *.png|*.gif|*.bmp)
            outfile="${1%.*}.jpg"
            CMD=( convert )
            ;;
        *.flac)
            outfile="${1%.*}.mp3"
            CMD=( ~/dotfiles/utils/flac2mp3.sh )
            ;;
        *.ogg)
            # temporarily ignore ogg files
            return
            ;;
        *.wav|*.mood|*.log|*.cue|*.AVI|*.mid|*.md5|*.ffp|*.sh|*.m3u|*.pdf|*.css)
            # silently ignore some file types
            return
            ;;
        *)
            :: "\e[1;31mIgnoring unknown filetype \e[1;37m*.${1##*.}\e[1;31m:\e[0m ${1}"
            return
            ;;
    esac
    outfile="$destdir/$outfile"
    infile="$srcdir/$1"
    if [[ -f "$outfile" && ! "$infile" -nt "$outfile" ]] ; then
        # if outfile exists and infile is not newer,
        # then outfile is up to date
        return
    fi
    #:: "$1 -> $outfile"
    :: "${CMD[@]}" "$infile" "$outfile" # || return 1
    mkdir -p "${outfile%/*}"
    "${CMD[@]}" "$infile" "$outfile" || return 1
}
export -f importfile


find "$1" -type f -printf '%P\n' | parallel --halt soon,fail=1 importfile
