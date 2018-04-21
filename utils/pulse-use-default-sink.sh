#!/usr/bin/env bash

# moves all existing playback streams to the default sink

set -e
sink=$(LC_ALL=C pactl info \
    | grep -m 1 '^Default Sink: ' \
    | sed 's,^Default Sink: ,,')

for stream in $( LC_ALL=C pactl list short sink-inputs|cut -f 1 ) ; do
    pactl move-sink-input "$stream" "$sink"
done

