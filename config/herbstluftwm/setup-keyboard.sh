#!/usr/bin/env bash

# setup keyboard

get-keyboard-options() {
    # given the xinput device name of a keyboard,
    # set an array 'options' with setxkbmap parameters
    # for this keyboard
case "$1" in
*"HID 04d9:0134") # no * at the end, here
   # pure kbtalking (60%)
   options=( -option compose:ralt
             -option compose:rctrl
             -option compose:rwin )
    ;;
*"AT Translated Set 2 keyboard"*)
    # thinkpad keyboard
    options=( -option compose:menu -option ctrl:nocaps -option compose:prsc )
    ;;
*"ARCHISS PTR66 ARCHISS PTR66"*)
    # progrestouch retro tiny (black 60% arrow keys)
    options=( -option compose:menu -option compose:rctrl -option ctrl:nocaps )
    ;;
*)
    options=( )
    ;;
esac
}

::() {
    echo ":: $*" >&2
    "$@"
}

mapfile xinputs < <(xinput list --short | grep 'slave[ ]* keyboard'|cut -f 1,2)

echo "Clearing existing options:"
:: setxkbmap -option
global_options=( -option ctrl:nocaps -option compose:menu )
:: setxkbmap us -variant altgr-intl "${global_options[@]}"

for line in "${xinputs[@]}" ; do
    name=$(cut -f 1 <<< "$line"|sed 's,^[ ]* ,,;s,[ ]* $,,')
    id=$(cut -f 2 <<< "$line")
    id="${id#id=}"
    get-keyboard-options "$name"
    if [[ "${#options[@]}" -eq 0 ]] ; then
        continue
    fi
    echo "Configuring device $id \"$name\"."
    :: setxkbmap -device "$id" "${options[@]}"
done

# try to replace an existing ibus-daemon:
:: herbstclient spawn ibus-daemon --replace


# old code:
# has-kbd() {
#     lsusb | grep "ID $*" > /dev/null
# }
# 
# hc keyunbind --all
# 
# keyboard=
# if has-kbd 04d9:0134 Holtek Semiconductor ; then # pure kbtalking
#     setxkbmap us -variant altgr-intl -option compose:menu -option ctrl:nocaps -option compose:ralt -option compose:rwin
# elif has-kbd 04d9:0112 Holtek Semiconductor ; then # kbparadise V60 Mini
#     setxkbmap us -variant altgr-intl -option compose:menu -option ctrl:nocaps -option compose:rwin
#     keyboard=v60mini
# elif has-kbd 2be8:0004 ; then # Progres Touch Retro Tiny
#     setxkbmap us -variant altgr-intl -option compose:rctrl -option ctrl:nocaps
# elif false ; then # mac
#     setxkbmap us -variant altgr-intl -option compose:menu -option ctrl:nocaps -option compose:ralt -option compose:rctrl
#     xmodmap -e 'keycode any 94 = grave'
# elif [[ $HOSTNAME == x1 ]] ; then
#     setxkbmap us -variant altgr-intl -option compose:menu -option ctrl:nocaps -option compose:prsc
# else
#     setxkbmap us -variant altgr-intl -option compose:menu -option ctrl:nocaps -option compose:ralt -option compose:rwin
# fi

