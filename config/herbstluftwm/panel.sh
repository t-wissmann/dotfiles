#!/bin/bash

set -f

monitor=${1:-0}
height=14
bottom=false
geometry=( $(herbstclient monitor_rect $monitor) )
# geometry has the format: X Y W H
x=${geometry[0]}
y=${geometry[1]}
$bottom && y=$((${geometry[1]}+${geometry[3]}-height))
width="${geometry[2]}"
font="-*-fixed-medium-*-*-*-12-*-*-*-*-*-*-*"
bgcolor='#0a0a0a'
icondir=~/.config/herbstluftwm/icons/

function uniq_linebuffered() {
    exec awk '$0 != l { print ; l=$0 ; fflush(); }' "$@"
}

update_pad() {
    $bottom && herbstclient pad $monitor "" "" "$1" \
            || herbstclient pad $monitor "$1"
}

activecolor="$(herbstclient attr theme.tiling.active.color)"

separator="^bg()^fg(#F3602C)|^fg()"
case "$HOSTNAME" in
    hoth)
        suspend="^ca(1,systemctl suspend)s2r^ca()"
        en="^ca(1,setxkbmap us && xmodmap ~/.xmodmaprc)EN^ca()"
        de="^ca(1,setxkbmap de && xmodmap ~/.xmodmaprc)DE^ca()"
        buttons="$suspend$separator$en$separator$de"
    ;;
    *)
        buttons=""
esac

update_pad $height
{
    # events:
    #mpc idleloop player &
    while true ; do
        date +'date ^fg(#898989)%H:%M, %Y-%m-%d'
        sleep 2 || break
    done > >(uniq_linebuffered) &
    child="$!"
    if [ "$HOSTNAME" = ghul ] ; then
        conky -c ~/.conkyrc 2> /dev/null &
        child="$child $!"
    fi
    herbstclient --idle
    kill $child
}|{
    TAGS=( $(herbstclient tag_status $monitor) )
    visible=true
    windowtitle=""
    conky=""
    date=""
    yoffset=0
    $bottom && yoffset=2
    while true ; do
        hintcolor="#0f0f0f"
        #separator=""
        #echo -n "^pa(0;0)"
        # draw tags
        echo -n "^bg($hintcolor)"
        for i in "${TAGS[@]}" ; do
            case ${i:0:1} in
                '#') #echo -n "^fg(#9fbc00)"
                     echo -n "^bg($activecolor)^fg(#000000)" ;;
                #'.') echo -n "^bg($hintcolor)^fg(black)" ;;
                '.') continue ;;
                '!') echo -n "^bg(#FF7386)^fg(black)" ;;
                *) echo -n "^bg(#454545)^fg(black)" ;;
                #':')
                #    echo -n "^fg(#efefef)"
                #    ;;
                #'+')
                #    echo -n "^fg(#FFBB00)"
                #    ;;
                #'!')
                #    echo -n "^fg(#FF0675)"
                #    ;;
                #'-')
                #    echo -n "^fg(#ffaa99)"
                #    ;;
                #'%')
                #    echo -n "^fg(#00ffbb)"
                #    ;;
                #*)
                #    echo -n "^bg()^fg(#676767)"
                #    ;;
            esac
            icon="$icondir/${i:1}"
            echo -n "^ca(1,herbstclient focus_monitor $monitor && herbstclient use ${i:1})"
            [ -f "$icon" ] && echo -n " ^pa(;$((yoffset+2)))^i($icon)^pa(;$yoffset) " \
                            || echo -n " ${i:1} "
            #echo -n "^ca()$separator"
            echo -n "^ca()"
        done
        echo -n "^bg()^fg(white) ${windowtitle//^/^^}^p(_CENTER)"
        # small adjustments
        calclick="^ca(1,$HOME/.config/herbstluftwm/calendar.sh)"
        calclick+="^ca(2,killall calendar.sh)"
        right="$conky$separator$buttons$separator^bg($hintcolor)$calclick $date ^ca()^ca()$separator"
        right_text_only=$(echo -n "$right"|sed 's.\^[^(]*([^)]*)..g')
        # get width of right aligned text.. and add some space..
        rightwidth=$(textwidth "$font" "$right_text_only  ")
        echo -n "^p(_RIGHT)^p(-$rightwidth)$right"
        # some nice bars
        #if $bottom ; then
        #  echo -n "^ib(1)^fg(#141414)^pa(0;0)^ro(${width}x1)"
        #else
        #  echo -n "^ib(1)^fg(#141414)^pa(0;$((height-1)))^ro(${width}x1)"
        #fi
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
            conky)
                conky="${cmd[@]:1}"
                ;;
            togglehidepanel)
                currentmonidx=$(herbstclient list_monitors |grep ' \[FOCUS\]$'|cut -d: -f1)
                if [ -n "${cmd[1]}" ] && [ "${cmd[1]}" -ne "$monitor" ] ; then
                    continue
                fi
                if [ "${cmd[1]}" = "current" ] && [ "$currentmonidx" -ne "$monitor" ] ; then
                    continue
                fi
                echo "^togglehide()"
                if $visible ; then
                    visible=false
                    echo "^lower()"
                    update_pad 0
                else
                    visible=true
                    echo "^raise()"
                    update_pad $height
                fi
                ;;
            quit_panel)
                #herbstclient pad $monitor 0
                exit
                ;;
            focus_changed|window_title_changed)
                windowtitle="${cmd[@]:2}"
                ;;
            reload)
                exit
                ;;
            #player)
            #    ;;
        esac
        done
} |dzen2 -e '' -w $width -x $x -y $y -fn "$font" -h $height \
    -ta l -bg "$bgcolor" -fg '#efefef'

#herbstclient pad $monitor 0


