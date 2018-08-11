#!/usr/bin/env bash

# from simigern
geometry=$(xwininfo -root | grep 'geometry' | awk '{print $2}')
xwd -root \
    | convert xwd:- -scale 5% -scale "!${geometry}" png:- \
    | exec i3lock -f -i /dev/stdin

