#!/bin/bash -e

# create man page dir for non-globally installed
# programes

shopt -s nullglob

# setting up a man-dir in ~/man
::() {
    echo -e "\e[0;31m:: \e[0;32m$*\e[0m"
}

MANDIR=$HOME/man
for d in "$MANDIR" "$MANDIR"/man{0..8} ; do
    :: Creating "$d"
    mkdir -p "$d"
done

searchdir=(
    ~/git/herbstluftwm/doc/
    ~/git/qutebrowser/doc/
    ~/git/rofi/doc/
    ~/git/katarakt/doc/
    ~/git/git-remote-hg/doc/
)

for d in "${searchdir[@]}" ; do
    :: Searching for man pages in "$d"
    for f in "${d%/}"/*.[0-8] ; do
        section="${f##*.}"
        target="${MANDIR}/man$section"
        :: Linking "${target##${MANDIR%/}/}/ <- ${f#$d}"
        ln -sf "$f" "$target"
    done
done

cat <<EOF
# Add the following to your bash configuration:
# extend man-variable
if [ -d "\${HOME}/man" ] ; then
    export MANPATH="\${HOME}/man:\${MANPATH}"
fi
EOF



