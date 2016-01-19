#!/bin/bash -e

::() { echo -e ":: $*" >&2 ; } ; export -f ::
export srcdir="$1"
export destdir=.

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
mapfile -t outputfiles < <(find "$1" -xtype f -printf '%P\n' | parallel --halt soon,fail=1 importfile|sort|uniq)

# now print all files that are in $destdir but not generated by this script
:: Files that have been deleted in "$1":
comm -23 <(find "$destdir" -xtype f -printf '%P\n' |sort ) <(printf "%s\n" "${outputfiles[@]}")
:: Files which should have been created:
comm -13 <(find "$destdir" -xtype f -printf '%P\n' |sort ) <(printf "%s\n" "${outputfiles[@]}")

