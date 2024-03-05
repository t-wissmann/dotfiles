#!/bin/bash

#echo \
#'┌─────┐ '\
#'│     │ '\
#'├┬ ' \
#'└─────┘'
#'┡ '

internal=LVDS1
ext=VGA1

xrandr_output=$(xrandr)
internal=$(echo "$xrandr_output"|grep primary|cut -d' ' -f1)
ext=$(echo "$xrandr_output"|grep ' 'connected| grep -v primary | head -n 1| cut -d' ' -f1)

all_other_outputs_off=( )
for output in $(echo "$xrandr_output"|grep -E ' (dis|)'connected|cut -d' ' -f1) ; do
    if [[ "$output" != "$internal" ]] && [[ "$output" != "$ext" ]] ; then
        all_other_outputs_off+=( --output "$output" --off )
    fi
done


external_on_top() {
#cat <<EOF
#┌────┬──┐
#│    │  │           External monitor ($ext)
#├────┘  │           on top of interal monitor ($internal)
#└───────┘
#EOF
cat <<EOF
┏━━━━┱──┐
┃    ┃  │           External monitor ($ext)
┡━━━━┛  │           on top of interal monitor ($internal)
└───────┘
EOF
}
external_right() {
#cat <<EOF
#┌───────┐ ┌────┐
#│       │ │    │   External monitor ($ext)
#│       │ └────┘   right of interal monitor ($internal)
#└───────┘
#EOF
cat <<EOF
┌───────┐ ┏━━━━┓
│       │ ┃    ┃   External monitor ($ext)
│       │ ┗━━━━┛   right of interal monitor ($internal)
└───────┘
EOF
}
external_left() {
cat <<EOF
┏━━━━┓ ┌───────┐
┃    ┃ │       │   External monitor ($ext)
┗━━━━┛ │       │   left of interal monitor ($internal)
       └───────┘
EOF
}
external_off() {
cat <<EOF
┌───────┐ ╭┄┄┄┄╮
│       │ ┆    ┆   Disable all external monitors ($ext)
│       │ ╰┄┄┄┄╯
└───────┘
EOF
}
internal_off() {
cat <<EOF
╭┄┄┄┄┄┄┄╮ ┏━━━━┓
┆       ┆ ┃    ┃   External monitor ($ext) enabled
┆       ┆ ┗━━━━┛   Internal monitor ($internal) disabled.
╰┄┄┄┄┄┄┄╯
EOF
}


print_menu() {
external_off
echo -ne '\0'
external_right
echo -ne '\0'
external_left
echo -ne '\0'
external_on_top
echo -ne '\0'
internal_off
}

update_hlwm() {
    herbstclient detect_monitors
    herbstclient reload
    # setxkbmap us -variant altgr-intl -option compose:menu -option ctrl:nocaps -option compose:ralt -option compose:rctrl
    xset -b
    # no tag locking if only one monitor
    herbstclient try and , compare monitors.count = 1 , unlock_tag
}

disable_screensaver() {
    xset -dpms
    xset s off
}

enable_screensaver() {
    xset +dpms
}

fix_hdmi_audio() {
    if [[ $(< /sys/class/drm/card0/*HDMI*/status) = connected ]] &&
       [[ "$1" != "force-disable" ]] ; then
        # echo "Audio output: HDMI"
        pactl set-card-profile 0 output:hdmi-stereo+input:analog-stereo
    else
        # echo "Audio output: analog"
        pactl set-card-profile 0 output:analog-stereo+input:analog-stereo
    fi
}

element_height=4
element_count=5

res=$(print_menu | rofi \
    -dmenu -sep '\0' -l "$element_count" \
    -eh "$element_height" -p '' -no-custom \
    -format i)

if [ -z "$res" ] ; then
    exit
fi

case "$res" in
    0)
        if [[ -z "$ext" ]] ; then
            xrandr "${all_other_outputs_off[@]}" --output "$internal" --auto --primary
        else
            xrandr --output "$ext" --off --output "$internal" --auto --primary
        fi
        enable_screensaver
        update_hlwm
        fix_hdmi_audio force-disable || true
        ;;
    1)
        xrandr --output $internal --auto --primary --output $ext --auto --right-of $internal
        update_hlwm
        disable_screensaver
        fix_hdmi_audio || true
        ;;
    2)
        xrandr --output $internal --auto --primary --output $ext --auto --left-of $internal
        update_hlwm
        disable_screensaver
        fix_hdmi_audio || true
        ;;
    3)
        xrandr --output $internal --auto --primary --output $ext --auto --pos 0x0
        update_hlwm
        disable_screensaver
        fix_hdmi_audio || true
        ;;
    4)
        xrandr --output $ext --auto --output $internal --off
        update_hlwm
        enable_screensaver
        fix_hdmi_audio || true
        ;;
    *)
        ;;
esac

