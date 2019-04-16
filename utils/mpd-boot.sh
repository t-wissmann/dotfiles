#!/usr/bin/env bash

ask() {
    local answer
    read -s -n 1 -p "$* [yN]" answer
    if [[ "$answer" == "y" ]] || [[ "$answer" == "Y" ]] ; then
        echo
        return 0
    else
        echo
        return 1
    fi
}

start_or_restart() {
    # start the given command
    # if is already running, restart it
    cmdname="$1"
    # 1. check if $cmdname is already running under the present user
    ps_output=$(ps -U thorsten -x)
    if line=$(grep " $cmdname$" <<< "$ps_output") ; then
        echo ":: Process $* already running:"
        echo "   $line"
        pid=$(sed 's,^[ ]*\([^ ]\+\) .*$,\1,' <<< "$line"|tr '\n' ' ')
        if ask "Kill $pid?" ; then
            kill $pid # drop spaces
        fi
    fi
    # 2. run it
    echo ":: Starting $*"
    nohup "$@" 2>> err.log >> out.log &
}

start_or_restart mpd
sleep 1 # hope that mpd boots up quick enough
start_or_restart mpdscribble
start_or_restart cantata
~/dotfiles/utils/mpd-volume2pulse.py &
