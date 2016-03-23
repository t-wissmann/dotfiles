#!/bin/bash

# find -mindepth 1 -type d  | while read -r d; do pushd "$d" ; [ -f play.m3u ] && continue ; echo "$d" ; ~/dotfiles/utils/folderplaylist.sh > play.m3u ; popd; done

# or for named playlists:
# find -mindepth 1 -type d  | while read -r d; do pushd "$d" ;  x="${d#./}" ; echo "${x//\// }" ; ~/dotfiles/utils/folderplaylist.sh > "${x//\// }".m3u ; popd; done
find -iname '*.mp3' | while read line ; do
    echo $(id3v2 -l "$line" |grep ^TRCK|sed 's,^.* ,,') "$line"
done|sort -n|sed 's,[^ ]* \(\./\)*,,' | sed 's,$,\r,'

