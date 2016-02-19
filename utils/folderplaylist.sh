#!/bin/bash

find -iname '*.mp3' | while read line ; do
    echo $(id3v2 -l "$line" |grep ^TRCK|sed 's,^.* ,,') "$line"
done|sort -n|sed 's,[^ ]* \./,,'

