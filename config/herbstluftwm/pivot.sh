#!/usr/bin/env bash
set -e


connected() {
    xrandr | grep "$1 connected.*$2" > /dev/null
}

case "$HOSTNAME" in
hoth)
    rotateoutput='DVI-D-0'
    args=( --left-of HDMI-0 )
    ;;
*)
    echo "I do not know what to rotate on $HOSTNAME" >&2
    exit 1
    ;;
esac

if connected "$rotateoutput" ' left (' ; then
    # rotate back to normal
    xrandr --output "$rotateoutput" --rotate normal "${args[@]}"
else
    xrandr --output "$rotateoutput" --rotate left "${args[@]}"
fi
herbstclient detect_monitors
~/git/herbstluftwm/share/restartpanels.sh
