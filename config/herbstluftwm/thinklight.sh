#!/bin/bash -e

# make the thinklight blink on urgent windows

file=${file:-/sys/class/leds/tpacpi\:\:thinklight/brightness}
interval=${interval:-0.2}
cycles=${cycles:-3}

die() { echo "$*" ; exit 1 ; }

test -f "$file" || die Error: thinklight file $file does not exist

herbstclient --idle '(reload|urgent)' on \
    | while read -a hook ; do
        echo "${hook[0]}" 
        if [ "${hook[0]}" = reload ] ; then
            kill $$
            break
        fi
        value=$(< $file )
        if [ "$value" -eq 0 ]
        then other_value="255"
        else other_value="0"
        fi
        for i in $(seq 1 $cycles) ; do
            echo "$other_value" > $file
            sleep $interval
            echo "$value" > $file
            sleep $interval
        done
    done
