#!/bin/bash -e

set -o pipefail

::() { echo -e ":: $*" >&2 ; } ; export -f ::
export srcdir="$1"
export destdir=.

flac2ogg() {
    oggenc -q 7 -o "$2" "$1"
}
export -f flac2ogg

importfile() {
    shopt -s nocasematch
    case "$1" in
        *.ogg|*.mp3|*.lyrics|*.txt|*.cue)
            outfile="$1"
            CMD=( ln -f )
            ;;
        *.jpg|*.jpeg)
            outfile="${1%/*}/folder.jpg"
            CMD=( ln -f )
            ;;
        *.png|*.gif|*.bmp)
            outfile="${1%/*}/folder.jpg"
            CMD=( convert )
            ;;
        *.flac)
            outfile="${1%.*}.mp3"
            CMD=( ~/dotfiles/utils/flac2mp3.sh )
            ;;
        # *.flac)
        #     outfile="${1%.*}.ogg"
        #     CMD=( flac2ogg ) # -o missing...
        #     ;;
        # *.ogg)
        #     # temporarily ignore ogg files
        #     return
        #     ;;
        *.py|*.wav|*.mood|*.log|*.AVI|*.mid|*.md5|*.ffp|*.sh|*.m3u|*.pdf|*.css|*.nzb|*.sfv|*.nfo)
            # silently ignore some file types
            return
            ;;
        *)
            :: "\e[1;31mIgnoring unknown filetype \e[1;37m*.${1##*.}\e[1;31m:\e[0m ${1}"
            return
            ;;
    esac
    # sanitize file names by dropping characters that aren't allowed in vfat.
    # according to wikipedia, the following are allowed in vfat:
    # ! # $ % & ' ( ) - @ ^ _ ` { } ~
    outfile=${outfile//\"/\'} # strangely, single quotes are allowed
    outfile=${outfile//[?:]/} # just drop them as there is no meaningful replacement
    echo "$outfile"
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

# convert the files, and remember the files that are created
# furthermore ignore duplicates, since some of the files may have multiple sources
# (e.g. if the cover image is present as both an jpg and png file)
parentpid=$BASHPID
export PARALLEL_SHELL=/bin/bash
mapfile -t outputfiles < <(find "$1" -xtype f -printf '%P\n' \
                           | parallel --halt soon,fail=1 importfile \
                           |sort|uniq \
                           || kill $parentpid )

# now print all files that are in $destdir but not generated by this script
:: Files that have been deleted in "$1":
comm -23 <(find "$destdir" -xtype f -printf '%P\n' |sort ) <(printf "%s\n" "${outputfiles[@]}")
:: Files which should have been created:
comm -13 <(find "$destdir" -xtype f -printf '%P\n' |sort ) <(printf "%s\n" "${outputfiles[@]}")

