#!/bin/bash

utf8db="$HOME/dotfiles/menu/utf8db"

if line=$(grep -v '^#' "$utf8db"|grep -v '^$' \
          |rofi -dmenu -i -p 'Zeichen' -columns 3) ; then
    #echo you selected "$line"
    # char is everything after the last space
    char=${line##* }
    #echo "you selected $char"
    #xdotool key "$char"
    echo -n "$char" |xclip -selection clipboard -i
    echo -n "$char" |xclip -selection primary -i
    # it is written to clipboard, now type it
    xdotool key shift+Insert
fi



