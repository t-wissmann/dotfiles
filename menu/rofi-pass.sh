#!/usr/bin/env bash

#set -e
# from passmenu
prefix=${PASSWORD_STORE_DIR-~/.password-store}
mapfile -t password_files < <(find "${prefix}" -name '*.gpg' -printf "%P\n"|sort)
password_files=( "${password_files[@]#"$prefix"/}" )
password_files=( "${password_files[@]%.gpg}" )
filter="$1"

clipwiz_key=Control-t
edit_key=Control-i
gen_key=Control-Shift-g
pkey() {
    printf "%-15s" "$*"
}

call_pass() {
    EDITOR="emacsclient -c --alternate-editor= " pass "$@"
}

terminal_pass() {
    rect=( $(herbstclient monitor_rect) )
    x=${rect[0]}+${rect[1]}
    y=${rect[1]}
    urxvt -override-redirect -geometry 60x8+$((x+10))+$((y+10)) -e pass "$@"
}

# detect whether we are run within qutebrowser
if [ -n "$QUTE_FIFO" ] ; then
    echo 'enter-mode insert' >> "$QUTE_FIFO"
fi
if [ -n "$QUTE_URL" ] ; then
    filter=${QUTE_URL#*://}
    filter=${filter%%/*}
    filter=${filter#www.}
fi

mesg="\
$(pkey Return       )| Auto-type
$(pkey $clipwiz_key )| Copy credentials to clipboard
$(pkey $gen_key     )| Generate a new entry
$(pkey $edit_key    )| Open in an editor"

rofi_args=(
    -p 'pass> '
    -format i
    -filter "$filter"
    -kb-custom-1 "$clipwiz_key"
    -kb-custom-2 "$gen_key"
    -kb-custom-3 "$edit_key"
    -mesg "$mesg"

)

idx=$(printf '%s\n' "${password_files[@]}" \
    | sed 's,/, → ,g' \
    | rofi "${rofi_args[@]}" -dmenu )
exit_code="$?"

if [[ "$exit_code" -eq 1 ]] ; then
    exit
else
        entry="${password_files[$idx]}"
fi

case "$exit_code" in
    0)
        ~/dotfiles/utils/pass-autotype.py "$entry"
        ;;
    10) # kb-custom-1
        terminal_pass clipwiz "$entry"
        ;;
    11) # kb-custom-2
        call_pass gen "$entry"
        ;;
    12) # kb-custom-3
        call_pass edit "$entry"
        ;;
    *)
        ;;
esac



