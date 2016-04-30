#!/bin/bash

set -f

monitor=${1:-0}
height=16
padding_top=0
padding_bottom=0
padding_left=0
padding_right=${padding_left}
bottom=0
geometry=( $(herbstclient monitor_rect $monitor) )
# geometry has the format: X Y W H
x=${geometry[0]}
y=${geometry[1]}
((bottom)) && y=$((${geometry[1]}+${geometry[3]}-height))
width="${geometry[2]}"

x=$((x + padding_left))
width=$((width - padding_left - padding_right))
y=$((y + padding_top))

font="-*-fixed-medium-*-*-*-12-*-*-*-*-*-*-*"
printf '%dx%d%+d%+d' $width $height $x $y
function uniq_linebuffered() {
    exec awk '$0 != l { print ; l=$0 ; fflush(); }' "$@"
}

update_pad() {
    ((bottom)) && herbstclient pad $monitor 0 0 "$1" \
               || herbstclient pad $monitor "$1"
}
debug() {
    echo "DEBUG: $*" >&2
}

keyboard_layouts=( us de )

activecolor="$(herbstclient attr theme.tiling.active.color)"
#activecolor="#9fbc00"

emphbg="#303030" #emphasized background color

update_pad $((height + padding_top + padding_bottom))
{
    # events:
    #mpc idleloop player &
    child=""
    #child+=" $!"
    while true ; do
        date +$'date\t%H:%M, %Y-%m-%d'
        sleep 2 || break
    done > >(uniq_linebuffered) &
    child+=" $!"
    herbstclient --idle
    kill $child
}|{
    TAGS=( $(herbstclient tag_status $monitor) )
    date=""
    layout="$(setxkbmap -query | grep ^layout:)"
    layout=${layout##* }
    conky=""
    while true ; do
        IFS=$'\t' read -ra cmd || break
        case "${cmd[0]}" in
            tag*)
                TAGS=( $(herbstclient tag_status $monitor) )
                ;;
            focus_changed|window_title_changed)
                windowtitle="${cmd[@]:2}"
                ;;
            date)
                date="${cmd[@]:1}"
                ;;
            quit_panel)
                exit 0
                ;;
            keyboard_layout)
                layout="${cmd[1]}"
                ;;
            *)
                ;;
        esac

        hintcolor="#0f0f0f"
        echo -n "%{l}%{A4:next:}%{A5:prev:}"
        for i in "${TAGS[@]}" ; do
            occupied=true
            focused=false
            here=false
            urgent=false
            visible=true
            case ${i:0:1} in
                # viewed: grey background
                # focused: colored
                '.') occupied=false ; visible=false
                    continue # hide them from taglist
                    ;;
                '#') focused=true ; here=true ;;
                '%') focused=true ;;
                '+') here=true ;;
                '!') urgent=true ;;
                # occupied tags
                ':') visible=false ;;
            esac
            tag=""
            $here     && tag+="%{B$emphbg}" || tag+="%{B-}"
            $visible  && tag+="%{+o}" || tag+="%{-o}"
            $occupied && tag+="%{F-}" || tag+="%{F#909090}"
            $urgent   && tag+="%{B#eeD6156C}%{-o}"
            $focused  && tag+="%{Fwhite}%{U$activecolor}" \
                      || tag+="%{U#454545}"
            tag+="%{A1:use_${i:1}:} ${i:1} %{A}"
            echo -n "$tag"
        done
        echo -n "%{A}%{A}%{F-}%{B-}%{-o}"
        [[ -n "$windowtitle" ]] \
            && echo -n "%{c} %{-o}%{U$activecolor}%{B$emphbg} ${windowtitle:0:50} %{-o}%{B-}" \
            || echo -n "%{c} "
        echo -n "%{r}"
        echo -n "%{B$emphbg}%{U$emphbg}%{+o}%{+u} "
        echo -n "%{A1:switchuser:}->[]%{A}"
        echo -n " %{B-}%{-o}%{-u}%{F-} "
        echo -n "%{B$emphbg}%{U$emphbg}%{+o}%{+u} "
        for l in "${keyboard_layouts[@]}" ; do
            if [[ "$l" == "$layout" ]] ; then
                flags="%{B$activecolor}%{Fblack}"
            else
                flags="%{B$emphbg}%{F-}"
            fi
            echo -n "%{A1:layout_$l:}$flags $l %{B$emphbg}%{A}"
        done
        echo -n " %{B-}%{-o}%{-u}%{F-} "
        echo -n "%{-o}%{U#909090}%{B$emphbg} $date %{B-}"
        echo "%{B-}%{-o}%{-u}"
    done
} | lemonbar -d \
    -g "$(printf '%dx%d%+d%+d' $width $height $x $y)" \
    -u 2 -f "$font" -B '#ee121212' | while read line ; do
    case "$line" in
        layout_*)
                layout="${line#layout_}"
                herbstclient emit_hook keyboard_layout "$layout"
                FLAGS=( -option compose:menu -option ctrl:nocaps
                        -option compose:ralt -option compose:rctrl )
                case "$layout" in
                    us) FLAGS+=( -variant altgr-intl ) ;;
                    *) ;;
                esac
                setxkbmap "${FLAGS[@]}" "$layout" 
            ;;
        use_*) herbstclient chain , focus_monitor "$monitor" , use "${line#use_}" ;;
        next)  herbstclient chain , focus_monitor "$monitor" , use_index +1 --skip-visible ;;
        prev)  herbstclient chain , focus_monitor "$monitor" , use_index -1 --skip-visible ;;
        switchuser) gdmflexiserver switch-to-greeter
    esac
done

#herbstclient pad $monitor 0


