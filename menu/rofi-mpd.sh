#!/bin/bash -e

#song_format="%position%) [[[%artist% - ]%title%[ (%album%)]]|[%file%]]"
song_format="[[%title%\n[by %artist%[ on %album%]]]|[%file%]]#|"
mpc --format "$song_format" playlist \
    | rofi -columns 2 -dmenu -p "mpd > " -sep "|" -eh 2

