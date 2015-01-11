#!/bin/bash

geom=$(xwininfo -root |
        grep -E 'Width:|Height:' |
        cut -d' ' -f4 |
        sed '1s/$/x/' |
        tr -d '\n')

hc() { herbstclient "$@" ; }

Mod=${Mod:-Mod4}

# create a floating tag
tag=floating
hc add "$tag"
hc floating "$tag" on

monitor=floatmon
# create a monitor
if ! hc add_monitor "$geom+0+0" "$tag" "$monitor" ; then
    # or move it if it already exists
    hc move_monitor "$monitor" "$geom+0+0"
fi

# remove all padding
hc pad "$monitor" 0 0 0 0
# pin the tag to that monitor
hc lock_tag "$monitor"

hc keybind "$Mod-Shift-f" move "$tag"

hc raise_monitor "$monitor"

