#!/bin/bash

hc() {
    herbstclient "$@"
}

panelcmd=${panelcmd:-~/.config/herbstluftwm/panel.sh}
if [ -x ~/dev/c/herbstluftwm/share/restartpanels.sh ] ; then
restartpanelcmd=${restartpanelcmd:-~/dev/c/herbstluftwm/share/restartpanels.sh}
else
restartpanelcmd=${restartpanelcmd:-~/git/herbstluftwm/share/restartpanels.sh}
fi


resolution=$(
     xwininfo -root |
        grep --binary-files=text -E ' Width: | Height: ' |  # only get width and height
        sort -r |                       # width first
        cut -d' ' -f4 |                 # only print values
        sed '1 s/$/x/' |                # append x to first line
        tr -d '\n'                      # join lines
    )

function dualhead() {
    width="$1"
    height="$2"
    hc set_monitors $((width/2))x$((height))+{0,$((width/2))}+0
}

function singlehead() {
    width="$1"
    height="$2"
    hc set_monitors $((width))x$((height))+0+0
}

cur_monitor_count=$(herbstclient list_monitors | wc -l)

if [ "$cur_monitor_count" -eq 1 ] ; then
    dualhead ${resolution/x/ }
else
    singlehead ${resolution/x/ }
fi

herbstclient emit_hook quit_panel

$restartpanelcmd $panelcmd

