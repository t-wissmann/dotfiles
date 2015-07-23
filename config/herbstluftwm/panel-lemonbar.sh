#!/bin/bash

set -f

monitor=${1:-0}
height=16
bottom=false
geometry=( $(herbstclient monitor_rect $monitor) )
# geometry has the format: X Y W H
x=${geometry[0]}
y=${geometry[1]}
$bottom && y=$((${geometry[1]}+${geometry[3]}-height))
width="${geometry[2]}"
font="-*-fixed-medium-*-*-*-12-*-*-*-*-*-*-*"
bgcolor='#0a0a0a'

function uniq_linebuffered() {
    exec awk '$0 != l { print ; l=$0 ; fflush(); }' "$@"
}

update_pad() {
    herbstclient pad $monitor "$1"
}
debug() {
    echo "DEBUG: $*" >&2
}

#activecolor="$(herbstclient attr theme.tiling.active.color)"
activecolor="#9fbc00"

update_pad $height
{
    # events:
    #mpc idleloop player &
    while true ; do
        date +$'date\t%H:%M, %Y-%m-%d'
        sleep 2 || break
    done > >(uniq_linebuffered) &
    child="$!"
    herbstclient --idle
    kill $child
}|{
    TAGS=( $(herbstclient tag_status $monitor) )
    date=""
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
            *)
                ;;
        esac

        hintcolor="#0f0f0f"
        echo -n "%{l}"
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
            $here     && tag+="%{B#323232}" || tag+="%{B-}"
            $visible  && tag+="%{+o}" || tag+="%{-o}"
            $occupied && tag+="%{F-}" || tag+="%{F#909090}"
            $urgent   && tag+="%{B#eeD6156C}%{-o}"
            $focused  && tag+="%{Fwhite}%{U$activecolor}" \
                      || tag+="%{U#454545}"
            tag+=" ${i:1} "
            echo -n "$tag"
        done
        echo -n "%{F-}%{B-}%{-o}"
        [[ -n "$windowtitle" ]] \
            && echo -n "%{c} %{-o}%{U#9fbc00}%{B#232323} ${windowtitle:0:50} %{-o}%{B-}" \
            || echo -n "%{c} "
        echo -n "%{r} %{-o}%{U#909090}%{B#232323} $date %{B-}"
        echo "%{B-}%{-o}%{-u}"
    done
} | lemonbar -d \
    -g "$(printf '%dx%d%+d%+d' $width $height $x $y)" \
    -u 2 -f "$font" -B '#ee121212'

#herbstclient pad $monitor 0


