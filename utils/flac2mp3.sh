#!/bin/bash -e

set -o pipefail
set -e

copytags() {
  set -o pipefail
  set -e
  # copies all the tags from the flac file $1 to the mp3 file $2
  eval "$(
     metaflac "$1" --no-utf8-convert \
                   --show-tag=ARTIST \
                   --show-tag=TITLE \
                   --show-tag=ALBUM \
                   --show-tag=GENRE \
                   --show-tag=TRACKNUMBER \
                   --show-tag=DISC \
                   --show-tag=DISCNUMBER \
                   --show-tag=DATE |
                   sed "s,[\"\'],\\\\&,g" |
                   sed "s,=\(.*\),=$\'\\1\'," |
                   sed "s,—,-,g" |
                   iconv -c -f UTF-8 -t ISO-8859-1 |
                   sed 's,^[^=]*,\U&,' # ensure upper case vars
    )" || return 1
  #flac -c -d "$f" | lame -m j -q 0 --vbr-new -V 0 -s 44.1 - "$outf"
  id3v2 -t "$TITLE" -T "${TRACKNUMBER:-0}" -a "$ARTIST" -A "$ALBUM" \
        -y "$DATE" -g "${GENRE:-12}" --TPOS "${DISC:-$DISCNUMBER}" "$2"
}

rm_and_fail() {
    #echo "Removing $1 again" >&2
    rm "$1"
    exit 1
}

convlocal() {
    ffmpeg -y -loglevel warning -i "$1" -ab 192k -ac 2 -ar 48000 "$2" \
        && copytags "$1" "$2" \
        || rm_and_fail "$2"
}

HOST=faui00u.cs.fau.de

convremote() {
    local curhost=$HOST
    #echo ":: $1 -> $2 on $host" >&2
    ssh "$curhost" \
        avconv -y -loglevel warning -i - -ab 196k -f mp3 -ac 2 -ar 48000 - \
        < "$1" > "$2" \
        && copytags "$1" "$2" \
        || rm "$2"
}

if [ "${1%%.flac}" = "$1" ] ; then
    echo "ERROR: $1 is not a flac file!" >&2
    exit 1
fi

output="$2"

if [ "${output%%.mp3}" = "$output" ] ; then
    echo "ERROR: $output is not a mp3 file!" >&2
    exit 1
fi

convlocal "$1" "$2"
#convremote "$1" "$2"

