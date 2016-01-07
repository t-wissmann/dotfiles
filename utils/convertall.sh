#!/bin/bash -e


::() { echo ":: $*" >&2 ; }
export -f ::

export srcdir=../musik/
export destdir=mp3/

:: Mirror directory structure
{
    cd "$srcdir"
    find -type d
} | {
    cd "$destdir"
    parallel mkdir -p
}

:: Hard-Linking
dolink() {
    infile="$1"
    destfile=${destdir}/${infile#$srcdir}
    if [ -f "$destfile" ] && ! [ "$destfile" -ot "$infile" ] ; then
        # if mp3 file exists and is newer than the flac file
        # then there is nothing to do
        return
    fi
    /usr/bin/echo "Creating $destfile" >&2 ;
    ln -f "$infile" "$destfile"
}
export -f dolink
{
find "$srcdir" -type f -iname 'cover.jpg'
find "$srcdir" -type f -iname 'cover.png'
find "$srcdir" -type f -iname '*.mp3'
} | parallel -j1 dolink

:: Convert flac files
doconv() {
    flacfile="$1"
    mp3file=${flacfile%.flac}.mp3
    mp3file=${destdir}/${mp3file#$srcdir}
    if [ -f "$mp3file" -a "$mp3file" -nt "$flacfile" ] ; then
        # if mp3 file exists and is newer than the flac file
        # then there is nothing to do
        return
    fi
    /usr/bin/echo "Creating $mp3file" >&2 ;
    ./flac2mp3.sh "$flacfile" "$mp3file" || rm --verbose -f "$mp3file"
}
export -f doconv
find "$srcdir" -type f -iname '*.flac' | parallel -j7 doconv

