#!/usr/bin/env bash

old="$1"
new="$2"

if [[ -z "$old" ]] || [[ -z "$new" ]] ; then
cat <<EOF
Usage: $0 OLD NEW

Produces a word-diff between the PDF files OLD and NEW.
EOF
exit 1
fi

mypdf2text() {
# add
#
#       -W 453 -y 62 -H 651 \
#
# to remove running headers and footers the -W and -H parameters are
# from pdfinfo of the page and we skip the first 62 (points or pixels, I
# don't know) such that the runnig header is removed
pdftotext -nopgbrk \
    "$1" - \
    | sed 's,ﬁ,fi,g' \
    | sed 's,ﬂ,fl,g' \
    | sed 's,ﬃ,ffi,g' \
    | sed 's,ﬀ,ff,g'
}

# git-diff does not support process substitution, so lets make temporary
# files... this leaks filenames to other users, but I don't care for the
# moment...
OLD_TXT=`mktemp --suffix="${old##*/}"` || exit 1
NEW_TXT=`mktemp --suffix="${new##*/}"` || exit 1
mypdf2text "$old" > "$OLD_TXT" || true
mypdf2text "$new" > "$NEW_TXT" || true

git diff --no-index --color=always --word-diff=color --ignore-all-space \
     "$OLD_TXT" "$NEW_TXT" || true

rm "$OLD_TXT" "$NEW_TXT"



# vim: tw=72
