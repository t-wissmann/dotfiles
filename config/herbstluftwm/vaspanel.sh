#!/bin/bash

set -f

monitor=0
height=20
bottom=${1:-false}
geometry=( $(herbstclient monitor_rect $monitor) )
# geometry has the format: X Y W H
x=${geometry[0]}
y=${geometry[1]}
$bottom && y=$((${geometry[1]}+${geometry[3]}-height))
width="${geometry[2]}"
font="-*-fixed-medium-*-*-*-16-*-*-*-*-*-*-*"
bgcolor='#0a0a0a'
icondir=~/.config/herbstluftwm/icons/

function uniq_linebuffered() {
    exec awk '$0 != l { print ; l=$0 ; fflush(); }' "$@"
}

update_pad() {
    $bottom && herbstclient pad $monitor "" "" "$1" \
            || herbstclient pad $monitor "$1"
}

to_titel() {
    index2title=(
    [0]="Begrüßung"
    [1]="TOP 1: "
    [2]="TOP 2: "
    [3]="Verabschiedung"
    )
}

redner_namen() {
    index2title=(
    [0]="Moderatoren"
    [1]="TBA"
    [2]="TBA"
    [3]="Moderatoren"
    )
}

$bottom && redner_namen || to_titel

# get border active color from current theme
activecolor="$(herbstclient attr theme.tiling.active.color)"

update_pad $height
{
    herbstclient --idle
    #kill $child
}|{
    TAGS=( $(herbstclient tag_status $monitor) )
    tag_index=( herbstclient attr tags.focus.index )
    visible=true
    yoffset=0
    $bottom && yoffset=2
    while true ; do
        hintcolor="#0f0f0f"
        #separator=""
        #echo -n "^pa(0;0)"
        # draw tags
        for i in "${!TAGS[@]}" ; do

            # IF TITLE IS EMPTY -> SKIP IT!
            [[ -z "${index2title[$i]}" ]] && continue

            case ${TAGS[$i]:0:1} in
                '#') #echo -n "^fg(#9fbc00)"
                     echo -n "^bg($activecolor)^fg(white)" ;;
                #'.') echo -n "^bg($hintcolor)^fg(black)" ;;
                *) echo -n "^bg()^fg(white)" ;;
            esac
            echo -n " ${index2title[$i]} "
        done
        # small adjustments
        echo
        # wait for next event
        read line || break
        cmd=( $line )
        # find out event origin
        case "${cmd[0]}" in
            tag*)
                #echo "reseting tags" >&2
                TAGS=( $(herbstclient tag_status $monitor) )
                ;;
            quit_panel)
                #herbstclient pad $monitor 0
                exit
                ;;
            reload)
                exit
                ;;
            #player)
            #    ;;
        esac
        done
} |dzen2 -w $width -x $x -y $y -fn "$font" -h $height \
    -ta c -bg "$bgcolor" -fg '#efefef'

#herbstclient pad $monitor 0


