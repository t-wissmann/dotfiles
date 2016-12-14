#!/bin/bash

#echo \
#'┌─────┐ '\
#'│     │ '\
#'├┬ ' \
#'└─────┘'
#'┡ '

ext=VGA1
internal=LVDS1

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
external_off() {
cat <<EOF
┌───────┐ ╭┄┄┄┄╮
│       │ ┆    ┆   External monitor ($ext) disabled
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
external_on_top
echo -e '\0'
external_right
echo -e '\0'
external_off
echo -e '\0'
internal_off
}

update_hlwm() {
    herbstclient detect_monitors
    herbstclient reload
    setxkbmap us -variant altgr-intl -option compose:menu -option ctrl:nocaps -option compose:ralt -option compose:rctrl
    xset -b
}

disable_screensaver() {
    xset -dpms
    xset s off
}

enable_screensaver() {
    xset +dpms
}

res=$(print_menu | rofi -dmenu -sep '\0' -eh 5 -p '' -no-custom -format i)
if [ -z "$res" ] ; then
    exit
fi
case "$res" in
    0)
        xrandr --output $internal --auto --primary --output $ext --auto --pos 0x0
        disable_screensaver
        ;;
    1)
        xrandr --output $internal --auto --primary --output $ext --auto --right-of $internal
        disable_screensaver
        ;;
    2)
        xrandr --output $ext --off --output $internal --auto --primary
        enable_screensaver
        ;;
    3)
        xrandr --output $ext --auto --output $internal --off
        enable_screensaver
        ;;
    *)
        ;;
esac

update_hlwm

