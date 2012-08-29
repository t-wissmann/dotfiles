#!/bin/bash
source ~/.bash_settings

case "$1" in
    bring)
        name=Bring:
        action() {
            herbstclient bring "$@"
            xdotool windowactivate "$@"
        }
        ;;
    select|*)
        action() { xdotool windowactivate "$@" ; }
        name=Select:
        ;;
esac

id=$(wmctrl -l | $dmenu_command -l $dmenu_lines -p "$name") \
    && action ${id%% *}

