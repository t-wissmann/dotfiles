#!/usr/bin/env bash


::() {
    echo -e "\e[1;33m:: \e[0;32m$*\e[0m" >&2
    "$@"
}

# docking_station='043e:9a39 LG Electronics USA, Inc. USB Controls'
docking_station='17ef:30ad Lenovo USB3.1 Hub'

if :: lsusb |grep "$docking_station" > /dev/null ; then
    # get last word of last line
    output=$(xrandr | grep -v primary | grep -E ' connected|disconnected 3840x2160'| cut -d' ' -f1)
    if [ -z "$output" ] ; then
        echo "Error: no output found!" >&2
        xrandr
        exit 1
    else
        echo "Output detected: $output"
    fi
    :: xrandr --output eDP1 --auto --pos 0x0 --primary \
        --output "$output" --off
    sleep 1
    # variable will be used without quotes:
    laptop_resolution='--auto'
    laptop_resolution='--mode 1920x1200'
    :: xrandr --output eDP1 $laptop_resolution --pos 0x0 --primary \
        --output "$output" --pos 0x0 --auto
    resolution=$(xrandr --listmonitors | grep "$output" | sed 's,/[0-9]\+,,g' | grep -oE '[0-9]+x[0-9]+\+0\+0' | tail -n 1)
    :: herbstclient set_monitors "$resolution"
    :: herbstclient reload
    #:: ~/.config/alacritty/set-font.sh monospace
    if ls /sys/class/net/ | grep "^enp" > /dev/null ; then
        # activate wired network
        :: sudo -S netctl stop-all < /dev/null
        :: sudo -S netctl start ethernet-dhcp < /dev/null
    fi
else
    for output in $(xrandr --listmonitors|grep -oE ': \+[^ *]+'|sed 's,^: +,,') ; do
        if [[ "$output" != "eDP1" ]] ; then
            :: xrandr --output "$output" --off
        fi
    done
    :: xrandr --output eDP1 --auto
    herbstclient detect_monitors
    herbstclient reload
    if [[ "$(netctl is-active ethernet-dhcp)" = active ]] ; then
        # disable wired network
        :: sudo -S netctl stop-all < /dev/null
    fi
    #:: ~/.config/alacritty/set-font.sh default
fi


