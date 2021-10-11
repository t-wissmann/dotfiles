#!/usr/bin/env bash

# from simigern
geometry=$(xwininfo -root | grep 'geometry' | awk '{print $2}')
#xwd -root \
#    | convert xwd:- -scale 5% -scale '!'"${geometry}" png:- \
#    | exec i3lock -f -i /dev/stdin

# newer i3lock versions read the image twice, and so we need to do the following:
img_path="$HOME/.i3lock-blur.png"
xwd -root | convert xwd:- -scale 5% -scale '!'"${geometry}" png:- > "$img_path"
chmod 600 "$img_path"
i3lock --nofork -f -i "$img_path"
rm "$img_path"
