#!/bin/bash

monitor=${1:-0}
geometry="$(herbstclient list_monitors |grep "^$monitor:"|cut -d' ' -f2)"
# geometry has the format: WxH+X+Y
x="$(echo $geometry |cut -d'+' -f2)"
y="${geometry##*+}"
width="${geometry%%x*}"
panelwidth="${geometry%%x*}"
height=16
font="-*-fixed-medium-*-*-*-10-*-*-*-*-*-*-*"
bgcolor='#141414'

herbstclient pad $monitor $height
(
    # events:
    #mpc idleloop player &
    while true ; do
        date +'date ^fg(#efefef)%H:%M^fg(#909090), %Y-%m-^fg(#efefef)%d'
        sleep 1 || break
    done &
    herbstclient --idle
)|(
    TAGS=( $(herbstclient tag_status $monitor) )
    date=""
    while true ; do
        bordercolor="#26221C"
        hintcolor="#573500"
        separator="^fg(#656565)|^fg()"
        # draw tags
        for i in "${TAGS[@]}" ; do
            case ${i:0:1} in
                '#')
                    echo -n "^fg(#E8003C)"
                    ;;
                '+')
                    echo -n "^fg(#CE013C)"
                    ;;
                *)
                    echo -n "^fg()"
                    ;;
            esac
            echo -n " ${i:1} "
            echo -n "$separator"
        done
        echo -n "^bg()^p(_CENTER)"
        # small adjustments
        right="$separator $date $separator"
        right_text_only=$(echo -n "$right"|sed 's.\^[^(]*([^)]*)..g')
        # get width of right aligned text.. and add some space..
        width=$(textwidth "$font" "$right_text_only  ")
        echo -n "^p(_RIGHT)^p(-$width)$right"
        echo -n "^fg(black)^pa(0;$((height-1)))^ib(1)^ro(${panelwidth}x1)"
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
            date)
                #echo "reseting date" >&2
                date="${cmd[@]:1}"
                ;;
            #player)
            #    ;;
        esac
        done
) |dzen2 -w $width -x $x -y $y -fn "$font" -h $height \
    -ta l -bg "$bgcolor" -fg '#efefef'




