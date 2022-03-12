#!/usr/bin/env bash


::() {
    echo -e "\e[1;33m:: \e[0;32m$*\e[0m" >&2
    "$@"
}


if :: lsusb |grep "043e:9a39 LG Electronics USA, Inc. USB Controls" > /dev/null ; then
    # get last word of last line
    output=$(xrandr | grep -v primary | grep -E ' connected|disconnected 3840x2160'| cut -d' ' -f1)
    :: xrandr --output eDP1 --auto --pos 0x0 --primary \
        --output "$output" --off
    sleep 1
    :: xrandr --output eDP1 --auto --pos 0x0 --primary \
        --output "$output" --pos 0x0 --auto
    resolution=$(xrandr --listmonitors | grep "$output" | sed 's,/[0-9]\+,,g' | grep -oE '[0-9]+x[0-9]+\+0\+0' | tail -n 1)
    :: herbstclient set_monitors "$resolution"
    :: herbstclient reload
else
    for output in $(xrandr --listmonitors|grep -oE ': +[^ ]*'|sed 's,^: +,,') ; do
        if [[ "$output" != "eDP1" ]] ; then
            :: xrandr --output "$output" --off
        fi
    done
    herbstclient detect_monitors
    herbstclient reload
fi


