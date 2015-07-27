#!/bin/bash -e

update_hlwm() {
    herbstclient detect_monitors
    herbstclient reload
    setxkbmap us -variant altgr-intl -option compose:menu -option ctrl:nocaps -option compose:ralt -option compose:rctrl
    xset -b
}

if xrandr --current | grep "VGA1 connected (" > /dev/null ; then
    # switching to external monitor
    # VGA1 connected but not active
    xrandr --output VGA1 --auto --output LVDS1 --off
    update_hlwm
elif xrandr --current | grep "LVDS1 connected (" > /dev/null ; then
    # LVDS1 connected but not active
    # switching to internal display
    xrandr --output VGA1 --off --output LVDS1 --auto
    update_hlwm
    setxkbmap us -variant altgr-intl -option compose:menu -option ctrl:nocaps
fi


