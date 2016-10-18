#!/bin/bash

rect=( $(herbstclient and , monitor_rect , echo , get frame_gap , echo , monitor_rect -p +0) )

gap=${rect[4]}
x=$((${rect[0]} % 1920))
y=${rect[1]}
w=${rect[2]}
echo ${rect[@]}
h=$((${rect[3]} - ${rect[8]}))

exec /usr/bin/dmenu -x "$((x+gap))" -y "$((y+gap))" -w "$((w-2*gap))" -h "$((h-gap))" "$@"
