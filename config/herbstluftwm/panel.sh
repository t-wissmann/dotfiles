#!/bin/bash

monitor=${1:-0}
geometry="$(herbstclient list_monitors |grep "^$monitor:"|cut -d' ' -f2)"
# geometry has the format: WxH+X+Y
x="$(echo $geometry |cut -d'+' -f2)"
y="${geometry##*+}"
width="${geometry%%x*}"
height=14
font="-*-fixed-medium-*-*-*-12-*-*-*-*-*-*-*"
bgcolor='#242424'
icondir=~/.config/herbstluftwm/icons/

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
        hintcolor="#323232"
        separator="^bg()^fg(#141414)|^fg()"
        echo -n "^pa(0;0)"
        # draw tags
        for i in "${TAGS[@]}" ; do
            case ${i:0:1} in
                '#')
                    echo -n "^fg(#9fbc00)"
                    ;;
                '+')
                    echo -n "^fg(#CAFFAD)"
                    ;;
                *)
                    echo -n "^fg(#676767)"
                    ;;
            esac
            echo -n " ^pa(;2)^i($icondir/${i:1})^pa(;0) "
            echo -n "$separator"
        done
        echo -n "^bg()^p(_CENTER)"
        # small adjustments
        right="$separator^bg($hintcolor) $date $separator"
        right_text_only=$(echo -n "$right"|sed 's.\^[^(]*([^)]*)..g')
        # get width of right aligned text.. and add some space..
        rightwidth=$(textwidth "$font" "$right_text_only  ")
        echo -n "^p(_RIGHT)^p(-$rightwidth)$right"
        # some nice bars
        echo -n "^ib(1)^fg(#141414)^pa(0;$((height-1)))^ro(${width}x1)"
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




