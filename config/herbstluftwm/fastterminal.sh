#!/bin/bash

# give some space very fast for a terminal
# requires bc

# usage: 

bottom=false

[ "$1" = -b ] && bottom=true && shift
[ "$1" = -t ] && bottom=false && shift
[ "$1" = -h ] && echo "Usage: $0 [-h] [-b|-t] [RATIO]" && exit


ratio=${1:-0.2}
child1="(clients horizontal:0)"
child2=""
focus=0 # 1 means old, 0 means new frame

if $bottom ; then
    focus=$(echo "1-$focus"|bc)
    ratio=$(echo "1-$ratio"|bc -l)
    child2="$child1"
    child1=""
fi
args="vertical:$ratio:$focus"

herbstclient load "(split $args $child1 $(herbstclient dump) $child2 )"



