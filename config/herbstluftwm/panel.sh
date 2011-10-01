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

function uniq_linebuffered() {
    awk '$0 != l { print ; l=$0 ; fflush(); }' "$@"
}

herbstclient pad $monitor $height
(
    # events:
    #mpc idleloop player &
    while true ; do
        date +'date ^fg(#efefef)%H:%M^fg(#909090), %Y-%m-^fg(#efefef)%d'
        sleep 2 || break
    done | uniq_linebuffered &
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
                ':')
                    echo -n "^fg(#efefef)"
                    ;;
                '+')
                    echo -n "^fg(#CAFFAD)"
                    ;;
                '!')
                    echo -n "^fg(#FF0675)"
                    ;;
                *)
                    echo -n "^fg(#676767)"
                    ;;
            esac
            icon="$icondir/${i:1}"
            echo -n "^ca(1,herbstclient focus_monitor $monitor && herbstclient use ${i:1})"
            [ -f "$icon" ] && echo -n " ^pa(;2)^i($icon)^pa(;0) " || echo -n " ${i:1} "
            echo -n "^ca()$separator"
        done
        echo -n "^bg()^p(_CENTER)"
        # small adjustments
        calclick="^ca(1,$HOME/.config/herbstluftwm/calendar.sh)"
        calclick+="^ca(2,killall calendar.sh)"
        right="$separator^bg($hintcolor)$calclick $date ^ca()^ca()$separator"
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
            togglehidepanel)
                echo "^togglehide()"
                ;;
            quit_panel)
                exit
                ;;
            #player)
            #    ;;
        esac
        done
) |dzen2 -e '' -w $width -x $x -y $y -fn "$font" -h $height \
    -ta l -bg "$bgcolor" -fg '#efefef'




