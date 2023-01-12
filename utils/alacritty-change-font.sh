#!/usr/bin/env bash

values=(
   'Bitstream Vera Sans Mono'
   'terminus'
)
font="${values[1]}"

for socket in /run/user/`id -u`/Alacritty-${DISPLAY}-*.sock ; do
    if [ -e "$socket" ] ; then
        ALACRITTY_SOCKET="$socket" \
        alacritty msg \
            config --window-id '-1' \
                font.normal.family="$font"
    fi
done

