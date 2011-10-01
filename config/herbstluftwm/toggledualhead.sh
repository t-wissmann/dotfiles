#!/bin/bash

hc() {
    herbstclient "$@"
}

panelcmd=${panelcmd:-~/.config/herbstluftwm/panel.sh}
restartpanelcmd=${restartpanelcmd:-~/git/herbstluftwm/share/restartpanels.sh}

resolution=$(
     xwininfo -root |
        grep -E ' Width: | Height: ' |  # only get width and height
        sort -r |                       # width first
        cut -d' ' -f4 |                 # only print values
        sed '1 s/$/x/' |                # append x to first line
        tr -d '\n'                      # join lines
    )

function dualhead() {
    width="$1"
    height="$2"
    hc focus_monitor 0
    hc remove_monitor 1
    hc move_monitor 0 $((width/2))x$((height))+0+0 $pad
    hc use 1
    hc add_monitor $((width/2))x$((height))+$((width/2))+0 2 $pad
}

function singlehead() {
    width="$1"
    height="$2"
    hc focus_monitor 0
    hc remove_monitor 1
    hc move_monitor 0 $((width))x$((height))+0+0 $pad
}

cur_monitor_count=$(herbstclient list_monitors | wc -l)

if [ "$cur_monitor_count" -eq 1 ] ; then
    dualhead ${resolution/x/ }
else
    singlehead ${resolution/x/ }
fi

$restartpanelcmd $panelcmd

