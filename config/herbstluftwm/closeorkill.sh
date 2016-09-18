#!/usr/bin/env bash

# settings:
key="${key:-Alt-F4}"
countdown="${countdown:-2}" # after how many presses of $key is the window killed?

# adds a keybinding to close the focused window. After $countdown many failed
# attempts to close the window, it is killed using xkill.

set -o errexit
set -o pipefail

cmd=(
    keybind "$key" chain
        , close
        , and
            : silent new_attr int clients.focus.my_kill_countdown
            : set_attr clients.focus.my_kill_countdown "$countdown"
# if the counter was already set and counted down to 0
# then force-kill the client using xkill
        , and
            : compare clients.focus.my_kill_countdown = "0"
            : try substitute ID clients.focus.winid spawn xkill -id ID
            : try sprintf BODY
                "Killing »%s« (%s) after $countdown failed close attempts."
                clients.focus.title clients.focus.winid
                    spawn notify-send BODY
)

# substract
for i in $(seq 1 "$countdown") ; do
cmd+=(
    , and
        : compare clients.focus.my_kill_countdown = "$i"
        : set_attr clients.focus.my_kill_countdown "$((i-1))"
)
done

herbstclient "${cmd[@]}"

